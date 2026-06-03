# nix-config

个人 Nix flake，用来管理 Linux 桌面、独立 Home Manager 主机，以及通过 nix-darwin 管理的 macOS。系统配置和用户配置放在同一个仓库中，通过小型功能开关组合；Linux 桌面栈以 Wayland 为主。

[English README](./README.md)

## 截图

![Wayland desktop with Niri and Waybar](assets/screenshot1.png)
![Niri overview](assets/screenshot2.png)

## 为什么使用 Nix 和 NixOS

- 用代码管理系统、桌面和开发环境，避免零散的手工改动。
- 让配置可复现、可重建，避免“配置黑洞”。
- 获得清晰、可预测的包管理方式，以及容易复现的项目级开发环境。

## 配置理念

- 尽量通过 Nix 声明式表达系统和用户配置，避免一次性的命令式操作。
- 尽量把配置和包集中在 Home Manager 用户层，这样即使在非 NixOS 系统上也能复用大部分用户环境。
- 基础系统保持小而干净，不预装过多语言运行时或大型开发栈。
- 项目开发工具优先通过 Nix dev shell 提供，并由 `direnv` 自动激活。
- 如果项目本身没有 dev shell，就在上级目录补一个；难以用 Nix 表达的项目再回退到容器。
- 目标是让各机器配置保持最小、清晰、可复现。

## 桌面偏好

- Linux 桌面优先使用窗口管理器，而不是完整桌面环境，保持简单和低耦合。
- 偏键盘驱动，常见操作尽量通过快捷键完成。
- 终端和应用启动器是桌面体验的核心。
- 避免不必要的应用；优先使用轻量 TUI 工具，合适时使用 Web 应用。
- 状态栏保持极简，只显示日常真正需要的信息；冗余入口放到启动器里。
- 状态栏元素尽量集中到右上角，减少视觉干扰。
- 审美目标是平静、协调、够用，避免过度花哨。

## 仓库结构

- `flake.nix`：入口文件，使用 `flake-parts`、overlays 和自定义包集；内部通过 `pkgs.mypkgs.*` 使用，外部暴露为扁平的 flake `packages.*` 输出。
- `hosts/`：每台机器的定义，组合系统模块、Home Manager 模块和用户元信息。
  - `nixos/`：NixOS 系统主机。
  - `home/`：非 NixOS 机器的独立 Home Manager 主机。
  - `darwin/`：通过 nix-darwin 和 Home Manager 管理的 macOS 主机。
- `modules/`：可复用模块。
  - `system/`：NixOS 和 nix-darwin 系统模块，包括桌面、外设、macOS defaults、Homebrew、安全启动、显卡等。
  - `home/`：Home Manager 模块，包括 shell、编辑器、终端、Wayland/macOS 应用和主题。
- `options/`：自定义功能开关，例如 niri、walker、waybar、sunshine、nvidia、lanzaboote 等。
- `overlays/`：nixpkgs overlays。
- `pkgs/`：自定义包和资源。

## 主机配置

### NixOS 主机 (`nixosConfigurations`)

- `hasty-desktop`：日常主力机，包含 NVIDIA、lanzaboote 安全启动、greetd + niri、waybar、walker、Thunar、Sunshine 远程桌面。
- `vmware-desktop`：虚拟机变体，复用 niri + walker + waybar + greetd + Thunar + Sunshine，不包含 NVIDIA 和安全启动配置。

### 独立 Home Manager 主机 (`homeConfigurations`)

- `hasty-earningd`：工作开发服务器，非 NixOS，只通过独立 Home Manager 管理用户环境。
- `hasty-dev-server`：Alibaba Cloud Linux 开发服务器，通过独立 Home Manager 管理。

### macOS 主机 (`darwinConfigurations`)

- `hasty-mba`：MacBook 配置，使用 nix-darwin、Home Manager、nix-homebrew、Homebrew casks、macOS defaults 和 Darwin 专用字体/应用模块。

## 桌面与用户环境

- **窗口管理/会话**：Niri 来自 `niri-flake`，内置 Wayland 优先的环境变量。
- **登录/会话启动**：greetd，SDDM 可选。
- **状态栏和启动器**：Waybar 自定义样式，Walker 启动器。
- **锁屏和空闲**：swaylock，swayidle 可通过开关启用。
- **输入法**：fcitx5。
- **通知/OSD**：mako + avizo 音量/亮度提示。
- **显示器规则**：kanshi 管理多显示器 profile。
- **文件管理器**：Thunar。
- **远程桌面**：Sunshine 开关。
- **主题**：Stylix，加上 `pkgs/assets` 中整理过的壁纸和图标。
- **CLI 基础环境**：zsh + starship、zellij、direnv、git 默认配置、fzf，以及通过 `pkgs.mypkgs.*` 使用的自定义包。

## Neovim

Neovim 由 Home Manager 启用，并直接引用外部配置 `inputs.nvim-config`，仓库为 [Hastyshell/diy.nvim](https://github.com/Hastyshell/diy.nvim)，同步到 `~/.config/nvim`。额外的构建和运行时依赖已经预先包装好，包括 nixd、lua-language-server、stylua、nixfmt、statix、deadnix、rg、fzf、shellcheck/shfmt，以及 SQL/TOML/YAML/Markdown/GitHub Actions 相关工具，让 LSP、formatter 和 Telescope 开箱可用。

## 自定义选项

查看 `options/default.nix` 获取功能开关，例如 `custom.linux.desktop.wm.niri.enable`、`custom.linux.desktop.bar.waybar.enable`、`custom.nixos.graphics.nvidia.enable`、`custom.nixos.secureBoot.lanzaboote.enable`、`custom.nixos.desktop.remoteDesktop.sunshine.enable` 等。各主机通过组合这些开关来启用或关闭功能。

## NixOS 操作指南

从仓库根目录运行。机器上还没有 `nh` 时，首次切换直接用 `nixos-rebuild`：

```bash
sudo nixos-rebuild switch --flake .#hasty-desktop
```

需要切换其他 NixOS 主机时，把 `hasty-desktop` 替换成对应主机名，例如 `vmware-desktop`。

安装好 `nh` 后，日常操作可以使用：

```bash
# 切换 NixOS 主机
nh os switch . #hostname

# 测试 NixOS 主机
nh os test . #hostname
```

新 NixOS 机器：克隆仓库，在 `hosts/nixos/` 下选择或新增主机，调整 `globalOptions`，然后用对应的 `.#hostname` 执行 `nh os switch`。

## 独立 Home Manager 操作指南

新的独立 Home Manager 机器：在 `hosts/home/` 下新增主机，然后在仓库根目录激活对应的 `homeConfigurations` 输出：

```bash
nix --extra-experimental-features "nix-command flakes" \
  run .#homeConfigurations.hasty-dev-server.activationPackage
```

需要切换其他独立 Home Manager 主机时，把 `hasty-dev-server` 替换成对应的主机名，例如 `hasty-earningd`。

## macOS 操作指南

从仓库根目录运行：

```bash
cd /Users/hastyshell/Projects/nix-config
```

### 首次部署

```bash
sudo -E -H nix --option connect-timeout 60 --option download-attempts 10 \
  --extra-experimental-features "nix-command flakes" \
  run .#darwin-rebuild -- switch --flake .#hasty-mba
```

### 首次激活成功后的重建

```bash
sudo darwin-rebuild switch --flake .#hasty-mba
```

如果 `darwin-rebuild` 还不存在，继续使用首次部署命令。

### 首次接管 `/etc`

如果激活时报 `/etc/bashrc` 或 `/etc/zshrc` 存在未知内容：

```bash
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
```

然后重新运行部署命令。

### 已有 App 冲突

如果 Homebrew 报 `/Applications/*.app` 已经存在：

```bash
mv "/Applications/AppName.app" "$HOME/Desktop/AppName.app.before-nix"
```

然后重新运行部署命令。

### 临时代理

如果下载 GitHub/GitLab 超时或出现 `early EOF`：

```bash
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7890
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy
export ALL_PROXY=$all_proxy
export GIT_HTTP_VERSION=HTTP/1.1
```

然后重新运行首次部署命令。

### 预取 flake inputs

如果 flake input 下载持续失败：

```bash
nix --option connect-timeout 60 --option download-attempts 10 \
  --extra-experimental-features "nix-command flakes" \
  flake archive .
```

然后重新运行部署命令。

### 验证配置

```bash
nix --extra-experimental-features "nix-command flakes" \
  eval .#darwinConfigurations.hasty-mba.config.networking.hostName

nix --extra-experimental-features "nix-command flakes" \
  eval .#darwinConfigurations.hasty-mba.config.homebrew.casks --json

nix --extra-experimental-features "nix-command flakes" \
  eval .#darwinConfigurations.hasty-mba.config.fonts.packages --apply builtins.length
```

注意：

- 使用本仓库的 `.#darwin-rebuild`，不要直接运行 `sudo nix run github:nix-darwin/...`。
- 不要用 `sudo launchctl setenv` 配代理，SIP 可能会拦截。
- 如果 shell 集成、字体或 macOS defaults 没有立刻生效，重启终端、重新登录或重启系统。

## 致谢

- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)：许多配置参考自这里。
- [niksingh710/ndots](https://github.com/niksingh710/ndots)：flake 布局启发了本仓库的组织方式。
- [vimjoyer](https://github.com/vimjoyer)：他的 YouTube 视频帮助我理解了很多 Nix 核心概念。
- [nix-community/lanzaboote](https://github.com/nix-community/lanzaboote)：解决了和 Windows 双系统共存时的安全启动问题。
- [hercules-ci/flake-parts](https://github.com/hercules-ci/flake-parts)：让这个 flake 更像一个工程化软件项目。
- [sodiboo/niri-flake](https://github.com/sodiboo/niri-flake)：让 Niri 配置更直接、更可复现。
- [basecamp/omarchy](https://github.com/basecamp/omarchy)：参考了它的 Linux 桌面审美，并借用了两张喜欢的壁纸。
