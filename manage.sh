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
  "atuin"
  "bat"
  "blueman"
  "bottom"
  "dust"
  "eza"
  "fd"
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
  "handlr"
  "hypridle"
  "hyprlock"
  "keyd"
  "lazygit"
  "lua-language-server"
  "mailspring-bin"
  "mako"
  "neovim"
  "niri"
  "nm-connection-editor"
  "obsidian-bin"
  "openssh"
  "pavucontrol"
  "procs"
  "ripgrep"
  "rust-analyzer"
  "rustup"
  "sd"
  "slack-desktop-wayland"
  "starship"
  "stylua"
  "tree-sitter-bash"
  "tree-sitter-cli"
  "tree-sitter-json"
  "tree-sitter-rust"
  "tree-sitter-toml"
  "ttf-hackgen"
  "xdg-desktop-portal"
  "xdg-desktop-portal-gtk"
  "waybar"
  "wezterm-git"
  "wl-clipboard"
  "wlsunset"
  "nwg-bar"
  "xwayland-satellite"
  "yazi"
  "zellij"
  "zoxide"
)

CONFIG_TARGETS=(
  "atuin"
  "bat"
  "bottom"
  "delta"
  "eza"
  "fcitx5"
  "fish"
  "fuzzel"
  "hypr"
  "keyd"
  "lazygit"
  "mako"
  "niri"
  "nwg-bar"
  "nvim"
  "starship.toml"
  "systemd/user/hypridle.service"
  "waybar"
  "wezterm"
  "yazi"
  "zellij"
)

HOME_TARGETS=(
  ".gitconfig"
)

NVIM_TS_QUERY_LANGS=(
  "bash"
  "json"
  "rust"
  "toml"
)

NVIM_TS_QUERY_FILES=(
  "highlights"
  "injections"
  "folds"
  "indents"
  "locals"
)

backup() {
  echo "📦 現在の設定を $DOTFILES_DIR にバックアップします..."
  mkdir -p "$DOTFILES_DIR/.config"

  for target in "${CONFIG_TARGETS[@]}"; do
    src="$CONFIG_DIR/$target"
    dest="$DOTFILES_DIR/.config/$target"

    if [ -e "$src" ]; then
      if [ -L "$src" ]; then
        if [ "$(readlink -f "$src")" == "$dest" ]; then
          echo "  - Skipped (already linked): ~/.config/$target"
          continue
        fi
      fi

      mkdir -p "$(dirname "$dest")"
      rm -rf "$dest"
      cp -r "$src" "$dest"
      echo "  ✓ Saved: ~/.config/$target"
    fi
  done

  for target in "${HOME_TARGETS[@]}"; do
    src="$HOME/$target"
    dest="$DOTFILES_DIR/$target"

    if [ -e "$src" ]; then
      if [ -L "$src" ]; then
        if [ "$(readlink -f "$src")" == "$dest" ]; then
          echo "  - Skipped (already linked): ~/$target"
          continue
        fi
      fi

      rm -rf "$dest"
      cp -r "$src" "$dest"
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

  mkdir -p "$HOME/.cargo"
  touch "$HOME/.cargo/env.fish"
  touch .config/niri/local-config.kdl

  echo "⚙️ fcitx5 の設定を配置します..."
  if [ ! -d "$HOME/.local/share/fcitx5/themes/catppuccin-mocha-lavender" ]; then
    git clone https://github.com/catppuccin/fcitx5.git
    mkdir -p "$HOME/.local/share/fcitx5/themes/"
    cp -r ./fcitx5/src/* "$HOME/.local/share/fcitx5/themes"
    rm -rf ./fcitx5
    echo "  ✓ Installed: catppuccin fcitx5 themes"
  fi

  echo "⚙️ bat のテーマを配置します..."
  if [ ! -d "$CONFIG_DIR/bat/themes/" ]; then
    mkdir -p "$CONFIG_DIR/bat/themes"
    wget -P "$CONFIG_DIR/bat/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
    echo "  ✓ Installed: catppuccin bat themes"
  fi

  echo "🌳 nvim tree-sitter クエリを配置します..."
  install_nvim_ts_queries

  echo "⚙️ keyd の設定を配置します..."
  if [ -d "$CONFIG_DIR/keyd" ]; then
    sudo mkdir -p /etc/keyd
    sudo ln -sf "$CONFIG_DIR/keyd/default.conf" /etc/keyd/default.conf
    echo "  ✓ Linked: /etc/keyd/default.conf"
  fi

  echo "⚙️ keyd サービスを有効化します..."
  sudo systemctl enable --now keyd

  echo "⚙️ AIコミット生成スクリプトを配置します..."
  mkdir -p "$HOME/.local/bin"
  ln -snf "$DOTFILES_DIR/src/scripts/ai-commit-gen" "$HOME/.local/bin/ai-commit-gen"
  chmod +x "$DOTFILES_DIR/src/scripts/ai-commit-gen"
  echo "  ✓ Linked: ~/.local/bin/ai-commit-gen"

  echo "✅ デプロイ完了！"
}

install_nvim_ts_queries() {
  local query_root="$HOME/.local/share/nvim/site/queries"
  local base_url="https://raw.githubusercontent.com/neovim-treesitter"

  for lang in "${NVIM_TS_QUERY_LANGS[@]}"; do
    local dest="$query_root/$lang"
    mkdir -p "$dest"
    local installed=0
    local attempted=0
    for file in "${NVIM_TS_QUERY_FILES[@]}"; do
      attempted=$((attempted + 1))
      local url="$base_url/nvim-treesitter-queries-${lang}/main/queries/${file}.scm"
      if curl -fsSL -o "$dest/${file}.scm" "$url" 2> /dev/null; then
        installed=$((installed + 1))
      fi
    done
    echo "  ✓ $lang ($installed/$attempted query files)"
  done
}

install_packages() {
  echo "📥 必要なパッケージをインストールします ($OS)..."

  case "$OS" in
    cachyos | arch | archarm)
      if ! command -v paru > /dev/null 2>&1; then
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
