#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

if [ -f /etc/os-release ]; then
	. /etc/os-release
	OS=$ID
else
	OS=$(uname -s)
fi

ARCH_PACKAGES=(
	"deno"
	"firefox"
	"fish"
	"fcitx5"
	"fcitx5-configtool"
	"fcitx5-gtk"
	"fcitx5-mozc"
	"fcitx5-qt"
	"fuzzel"
	"git"
	"git-delta"
	"hypridle"
	"hyprlock"
	"kanata-bin"
	"lazygit"
	"lua-language-server"
	"mailspring-bin"
	"mako"
	"neovim"
	"niri"
	"obsidian-bin"
	"openssh"
	"overskride"
	"pavucontrol"
	"ripgrep"
	"rust-analyzer"
	"rustup"
	"slack-desktop-wayland"
	"starship"
	"stylua"
	"tree-sitter-cli"
	"ttf-hackgen"
	"xdg-desktop-portal"
	"xdg-desktop-portal-gtk"
	"waybar"
	"wezterm-git"
	"wl-clipboard"
	"wlogout"
	"xwayland-satellite"
	"yazi"
	"zellij"
	"zoxide"
)

CONFIG_TARGETS=(
    "fish"
    "fuzzel"
    "hypr"
    "kanata"
    "lazygit"
    "mako"
	"niri"
	"nvim"
    "starship.toml"
    "systemd/user/kanata.service"
    "waybar"
    "wezterm"
    "yazi"
    "zellij"
)

HOME_TARGETS=(
	".gitconfig"
)

backup() {
	echo "📦 現在の設定を $DOTFILES_DIR にバックアップします..."
	mkdir -p "$DOTFILES_DIR/.config"

	for target in "${CONFIG_TARGETS[@]}"; do
		if [ -e "$CONFIG_DIR/$target" ]; then
			mkdir -p "$(dirname "$DOTFILES_DIR/.config/$target")"
			cp -r "$CONFIG_DIR/$target" "$DOTFILES_DIR/.config/$target"
			echo "  ✓ Saved: ~/.config/$target"
		fi
	done

	for target in "${HOME_TARGETS[@]}"; do
		if [ -e "$HOME/$target" ]; then
			cp -r "$HOME/$target" "$DOTFILES_DIR/"
			echo "  ✓ Saved: ~/$target"
		fi
	done

	echo "✅ バックアップ完了！"
}

deploy() {
	echo "🔗 シンボリックリンクを展開します..."

	mkdir -p "$CONFIG_DIR"
	for target in "${CONFIG_TARGETS[@]}"; do
		if [ -e "$CONFIG_DIR/$target" ] && [ ! -L "$CONFIG_DIR/$target" ]; then
			mv "$CONFIG_DIR/$target" "$CONFIG_DIR/${target}.backup"
		fi
		mkdir -p "$(dirname "$CONFIG_DIR/$target")"
		ln -snf "$DOTFILES_DIR/.config/$target" "$CONFIG_DIR/$target"
		echo "  ✓ Linked: ~/.config/$target"
	done

	for target in "${HOME_TARGETS[@]}"; do
		if [ -e "$HOME/$target" ] && [ ! -L "$HOME/$target" ]; then
			mv "$HOME/$target" "$HOME/${target}.backup"
		fi
		ln -snf "$DOTFILES_DIR/$target" "$HOME/$target"
		echo "  ✓ Linked: ~/$target"
	done

	echo "⚙️ kanata の権限設定を確認します..."
	if ! groups "$USER" | grep -q input; then
		echo "  ⚠️ ユーザーを input/uinput グループに追加する必要があります。"
		sudo usermod -aG input "$USER"
		echo "  (設定反映には再ログインが必要です)"
	fi
	echo "⚙️ kanata ユーザーサービスを有効化します..."
	systemctl --user daemon-reload
	systemctl --user enable --now kanata.service

	echo "✅ デプロイ完了！"
}

install_packages() {
	echo "📥 必要なパッケージをインストールします ($OS)..."

	case "$OS" in
	cachyos | arch)
		if ! command -v paru >/dev/null 2>&1; then
			echo "❌ paru が見つかりません。先に paru をインストールしてください。"
			exit 1
		fi
		paru -S --needed "${ARCH_PACKAGES[@]}"
		;;
	*)
		echo "❌ 未対応のOSです: $OS"
		exit 1
		;;
	esac

	if [ "$SHELL" != "$(command -v fish)" ]; then
		echo "🐟 デフォルトシェルを fish に変更します..."
		sudo chsh -s "$(command -v fish)" "$USER"
	fi

	echo "✅ インストール完了！"
}

case "$1" in
backup) backup ;;
deploy) deploy ;;
install) install_packages ;;
*)
	echo "Usage: $0 {backup|deploy|install}"
	exit 1
	;;
esac
