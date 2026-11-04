#!/bin/bash
set -euo pipefail

# /root is the persistent volume; keep the public home and Nix paths stable.
state_dir=/root/.local/share/hasty-earningd
home_dir=/home/hastyshell
nix_profile=/nix/var/nix/profiles/default
runtime_dir=/run/hasty-earningd

die() {
	echo "hasty-earningd: $*" >&2
	exit 1
}

same_directory() {
	[[ -d "$1" && -d "$2" ]] && [[ $(stat -c '%d:%i' "$1") == "$(stat -c '%d:%i' "$2")" ]]
}

bind_directory() {
	local source=$1 target=$2
	mkdir -p "$source" "$target"
	if mountpoint -q "$target"; then
		same_directory "$source" "$target" || die "unexpected mount at $target"
	else
		[[ -z $(find "$target" -mindepth 1 -maxdepth 1 -print -quit) ]] || die "$target is not empty; merge its files before mounting"
		mount --bind "$source" "$target"
	fi
}

install_recovery_hook() {
	local profile temporary
	if [[ $(readlink -f "${BASH_SOURCE[0]}") != "$state_dir/restore.sh" ]]; then
		install -m 0700 "${BASH_SOURCE[0]}" "$state_dir/restore.sh"
	fi
	for profile in /root/.zshenv /root/.bash_profile; do
		if grep -qF '# hasty-earningd persistence' "$profile" 2>/dev/null; then
			continue
		fi
		temporary=$(mktemp "$state_dir/profile.XXXXXX")
		cat >"$temporary" <<HOOK
# hasty-earningd persistence: restore before a root login runs su or other commands.
if [ "\$(id -u)" = 0 ] && [ -s "$state_dir/nix-build-users" ]; then
  "$state_dir/restore.sh" || printf '%s\\n' 'hasty-earningd restore failed; inspect $state_dir/restore.sh' >&2
fi
HOOK
		if [[ -f "$profile" ]]; then
			cp -p "$profile" "$state_dir/$(basename "$profile").before-restore"
			cat "$profile" >>"$temporary"
		fi
		install -m 0644 "$temporary" "$profile"
		rm "$temporary"
	done
}

[[ $(id -u) == 0 ]] || die "run as root"
[[ ${1:-} == "" || ${1:-} == --prepare ]] || die "usage: $0 [--prepare]"
mountpoint -q /root || die "/root must be a persistent mount"
[[ $(findmnt -n -o FSTYPE -T /root) != overlay ]] || die "/root is on an ephemeral overlay"

install -d -m 0700 "$state_dir" "$runtime_dir"
exec 9>"$runtime_dir/restore.lock"
flock 9
if [[ -f "$runtime_dir/ready" ]] && same_directory "$state_dir/home" "$home_dir" && same_directory "$state_dir/nix" /nix; then
	exit 0
fi

# The base image owns several system paths as UID 1000 and strips sudo's setuid bit.
chown root:root / /etc /etc/systemd /etc/systemd/system
chmod 0755 /etc/systemd/system
chown root:root /usr/bin/sudo /usr/libexec/sudo /usr/libexec/sudo/* /etc/sudo.conf /etc/sudoers /etc/sudoers.d
chmod 4755 /usr/bin/sudo

if ! getent group hastyshell >/dev/null; then
	! getent group 1000 >/dev/null || die "GID 1000 is already in use"
	groupadd --gid 1000 hastyshell
fi
[[ $(getent group hastyshell | cut -d: -f3) == 1000 ]] || die "unexpected hastyshell GID"
if ! id hastyshell >/dev/null 2>&1; then
	! getent passwd 1000 >/dev/null || die "UID 1000 is already in use"
	useradd --no-log-init --uid 1000 --gid hastyshell --no-create-home --home-dir "$home_dir" --shell /bin/bash hastyshell
fi
[[ $(id -u hastyshell) == 1000 ]] || die "unexpected hastyshell UID"
usermod -aG wheel hastyshell
printf 'hastyshell ALL=(ALL:ALL) NOPASSWD: ALL\n' >/etc/sudoers.d/hastyshell
chown root:root /etc/sudoers.d/hastyshell
chmod 0440 /etc/sudoers.d/hastyshell
visudo -cq

bind_directory "$state_dir/home" "$home_dir"
bind_directory "$state_dir/nix" /nix
chown hastyshell:hastyshell "$home_dir"
chmod 0700 "$home_dir"
chmod 0755 /nix

if [[ ${1:-} == --prepare ]]; then
	install_recovery_hook
	exit 0
fi
[[ -x "$nix_profile/bin/nix" ]] || die "Nix is not installed; run the first-install steps"
[[ -s "$state_dir/nix-build-gid" && -s "$state_dir/nix-build-users" ]] || die "missing saved Nix build accounts"

build_gid=$(cat "$state_dir/nix-build-gid")
if ! getent group nixbld >/dev/null; then
	groupadd --gid "$build_gid" nixbld
fi
[[ $(getent group nixbld | cut -d: -f3) == "$build_gid" ]] || die "unexpected nixbld GID"
while IFS=: read -r name uid; do
	if ! id "$name" >/dev/null 2>&1; then
		useradd --no-log-init --uid "$uid" --gid nixbld --groups nixbld --no-create-home --home-dir /var/empty --shell /usr/sbin/nologin "$name"
	fi
	[[ $(id -u "$name") == "$uid" ]] || die "unexpected UID for $name"
done <"$state_dir/nix-build-users"

install -d -m 0755 /etc/nix
install -m 0644 "$state_dir/nix.conf" /etc/nix/nix.conf
cat >/etc/profile.d/nix.sh <<'PROFILE'
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
PROFILE
chmod 0644 /etc/profile.d/nix.sh
ln -sfn "$nix_profile/lib/systemd/system/nix-daemon.service" /etc/systemd/system/nix-daemon.service
ln -sfn "$nix_profile/lib/systemd/system/nix-daemon.socket" /etc/systemd/system/nix-daemon.socket
install -d -m 0755 /etc/tmpfiles.d
ln -sfn "$nix_profile/lib/tmpfiles.d/nix-daemon.conf" /etc/tmpfiles.d/nix-daemon.conf
systemd-tmpfiles --create --prefix=/nix/var/nix
systemctl daemon-reload
systemctl enable --now --quiet nix-daemon.socket

if [[ -x "$home_dir/.nix-profile/bin/zsh" ]]; then
	shell="$home_dir/.nix-profile/bin/zsh"
	grep -qxF "$shell" /etc/shells || echo "$shell" >>/etc/shells
	usermod --shell "$shell" hastyshell
fi
touch "$runtime_dir/ready"
