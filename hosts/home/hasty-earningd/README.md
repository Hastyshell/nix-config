# hasty-earningd

Coder 开发环境：Rocky Linux 9、`aarch64-linux`，用户 `hastyshell`，逻辑家目录
`/home/hastyshell`。只用独立 Home Manager 管理 CLI，不安装 Java / Maven，不启用
GPU 驱动集成。Git 邮箱仍沿用原配置，可修改 `default.nix` 中的 `email`。

## 存储与恢复机制

这个模板停止、启动工作区时会重建容器。已实际确认：只有 `/root` 挂载了保留的本地卷，
`/` 是临时 overlay。`df` 中 `/` 的可用空间不能作为持久容量使用。

| 用户使用的路径 | 卷上实际存放位置 |
| --- | --- |
| `/home/hastyshell` | `/root/.local/share/hasty-earningd/home` |
| `/nix` | `/root/.local/share/hasty-earningd/nix` |

通过 bind mount 保持用户家目录和 Nix store 的绝对路径不变，无需放宽 `/root` 权限。
`restore.sh` 在容器重建后恢复挂载、UID/GID、免密 sudo、Nix 构建用户、daemon 和登录 shell。
脚本遇到非空且未挂载的目标目录会停止，避免隐藏另一份数据。

恢复入口保存在 `/root/.zshenv` 和 `/root/.bash_profile`。使用原来的 SSH 命令时，
先由 root 的 shell 恢复环境，然后才执行 `su`：

```sh
ssh -t hastyshell@main.hastyshell-dev.siyangtang.coder 'su - hastyshell'
```

**这是首次登录时恢复，不是 Pod 启动时恢复。** 若需要无人登录时也立即启动依赖这些目录的
后台服务，需要管理员把以下命令加入 Coder 模板 startup script：

```sh
/root/.local/share/hasty-earningd/restore.sh
```

当前没有修改公司 Coder 模板。该卷是节点上的本地存储，不代表跨节点故障或删除工作区也有保障；
重要代码仍应提交和备份。共享卷的可用容量以 `df -h /root` 为准，不是本工作区的独占额度。
可重新生成的大型构建文件、缓存可以放在 `/tmp`；它使用另一块临时盘，容器重建后会丢失。

## 首次安装

先将当前仓库（含未提交改动）同步到
`/root/.local/share/hasty-earningd/source`。然后以 root 执行：

```sh
state=/root/.local/share/hasty-earningd
repo="$state/source"
install -d -m 0700 "$state"
install -m 0700 "$repo/hosts/home/hasty-earningd/restore.sh" "$state/restore.sh"
install -m 0644 "$repo/hosts/home/hasty-earningd/nix.conf" "$state/nix.conf"
"$state/restore.sh" --prepare
mkdir -p /home/hastyshell/.config
cp -a "$repo" /home/hastyshell/.config/nix-config
chown -R hastyshell:hastyshell /home/hastyshell/.config

dnf install -y xz tar bzip2 ca-certificates
curl -fsSL https://nixos.org/nix/install -o "$state/install-nix.sh"
sh "$state/install-nix.sh" --daemon --yes --no-channel-add

# 保存精确的构建用户 ID；容器重建后 /etc/passwd 和 /etc/group 会丢失。
getent group nixbld | cut -d: -f3 > "$state/nix-build-gid"
getent passwd | awk -F: '$1 ~ /^nixbld[0-9]+$/ {print $1 ":" $3}' > "$state/nix-build-users"
"$state/restore.sh"
systemctl restart nix-daemon.service
```

Nix 优先使用交大镜像，保留官方、numtide、nix-community 缓存，并验证签名和内容。
以普通用户构建和激活：

```sh
su - hastyshell
cd ~/.config/nix-config
nix build .#homeConfigurations.hasty-earningd.activationPackage --out-link /tmp/hasty-earningd-home
HOME_MANAGER_BACKUP_EXT=before-home-manager /tmp/hasty-earningd-home/activate
```

首次激活后，root 设置登录 shell：

```sh
grep -qxF /home/hastyshell/.nix-profile/bin/zsh /etc/shells || \
  echo /home/hastyshell/.nix-profile/bin/zsh >> /etc/shells
usermod -s /home/hastyshell/.nix-profile/bin/zsh hastyshell
```

## 后续 rebuild 与检查

以 `hastyshell` 运行：

```sh
cd ~/.config/nix-config
home-manager switch --flake .#hasty-earningd
findmnt -T "$HOME"
findmnt -T /nix
df -h "$HOME" /nix
```

两条 `findmnt` 应指向 `/root` 对应的 XFS 卷，而不是 overlay。恢复失败时，root 可手动执行
`/root/.local/share/hasty-earningd/restore.sh`；安装和构建日志也保存在该持久目录。

## 项目的自动构建目录

每个项目在根目录的 `.envrc` 中加入一行（如果已有 `use flake`，放在它后面）：

```sh
use tmp_build
```

首次运行 `direnv allow`。以后进入项目时自动创建目录，退出项目时恢复原环境变量。
工作区重建后，重新进入项目会再次创建临时目录，无需手动 `mkdir`。
这个辅助函数只在本主机定义，团队共享的 `.envrc` 可以用
`if has use_tmp_build; then use tmp_build; fi` 兼容其他开发环境。

| 环境变量 | 用途 | 是否持久 |
| --- | --- | --- |
| `CARGO_TARGET_DIR` | Cargo 编译产物、增量缓存；`cargo build/test/bench` 自动使用 | 否 |
| `PROJECT_BUILD_DIR` | 通用构建目录，例如 `cmake -S . -B "$PROJECT_BUILD_DIR"` | 否 |
| `BENCH_DATA_DIR` | 可重新生成的性能测试数据，需显式传给测试程序 | 否 |
| `BENCH_RESULTS_DIR` | 家目录下的测试报告目录，需显式保存结果到这里 | 是 |

临时目录在 `/tmp/dev-build-<UID>/<项目路径哈希>/`，不同项目和 Git worktree 相互隔离。
目录设置不会安装 Rust 工具链；Rust 版本由项目自己的 devShell 或工具链配置管理。
脚本没有自动清理在用目录；Coder 重建会清除临时盘。

## 性能测试

当前工作区的 cgroup 上限是 16 CPU 时间配额和 32 GiB 内存，可见的 128 核属于宿主机。
CPU 没有独占绑定，因此共享负载、CPU 限流、磁盘竞争都可能影响结果。

`cargo bench` 默认使用优化后的 bench profile。测试时先完成编译，避免同时跑其他构建，
对比相同线程数、相同数据和相同配置的多轮结果。示例在项目已配置 benchmark 和工具链后使用：

```sh
run_id=$(date +%Y%m%d-%H%M%S)
report="$BENCH_RESULTS_DIR/$run_id"
mkdir -p "$report"
set -o pipefail
cargo bench 2>&1 | tee "$report/bench.log"
# Criterion 的基线和报告默认也在临时 target 下，需要时复制到持久目录。
if [ -d "$CARGO_TARGET_DIR/criterion" ]; then
  cp -a "$CARGO_TARGET_DIR/criterion" "$report/criterion"
fi
```

`/tmp` 是 NVMe 上的 XFS 文件系统，不是内存 tmpfs；它和 `/root` 位于不同的块设备上。
I/O 测试应显式选择数据目录，记录测试的是哪块盘、冷/热缓存条件以及结果；不要把两块盘上的
结果直接比较。需要稳定的正式性能基线时，应申请独占或有明确资源隔离的测试环境。
