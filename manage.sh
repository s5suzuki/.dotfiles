#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  OS=$(uname -s)
fi

case "$OS" in
  Darwin) OS_FAMILY="macos" ;;
  *) OS_FAMILY="linux" ;;
esac

ARCH_PACKAGES=(
  "atuin"
  "bat"
  "bottom"
  "btop"
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
  "fzf"
  "ghostty"
  "git"
  "git-delta"
  "handlr"
  "keyd"
  "lazygit"
  "lua-language-server"
  "neovim"
  "niri"
  "openssh"
  "procs"
  "ripgrep"
  "rust-analyzer"
  "rustup"
  "sd"
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
  "wl-clipboard"
  "xwayland-satellite"
  "yazi"
  "zellij"
  "zoxide"
)

MAC_PACKAGES=(
  "atuin"
  "bat"
  "bottom"
  "btop"
  "dust"
  "eza"
  "fd"
  "fish"
  "fzf"
  "git"
  "git-delta"
  "lazygit"
  "lua-language-server"
  "neovim"
  "procs"
  "ripgrep"
  "rust-analyzer"
  "rustup"
  "sd"
  "starship"
  "stylua"
  "tree-sitter-cli"
  "yazi"
  "zellij"
  "zoxide"
  "acsandmann/tap/rift"       
  "laishulu/homebrew/macism" 
)

MAC_CASKS=(
  "firefox"
  "ghostty"
  "font-hackgen"        
  "karabiner-elements" 
  "google-japanese-ime"
  "stats"             
  "raycast"          
)

CONFIG_TARGETS=(
  "atuin"
  "bat"
  "bottom"
  "delta"
  "btop"
  "eza"
  "fcitx5"
  "fish"
  "ghostty"
  "herdr/config.toml"
  "keyd"
  "lazygit"
  "niri"
  "noctalia"
  "nvim"
  "starship.toml"
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

  if [ "$OS_FAMILY" = "linux" ]; then
    echo "⚙️ fcitx5 の設定を配置します..."
    if [ ! -d "$HOME/.local/share/fcitx5/themes/catppuccin-mocha-lavender" ]; then
      git clone https://github.com/catppuccin/fcitx5.git
      mkdir -p "$HOME/.local/share/fcitx5/themes/"
      cp -r ./fcitx5/src/* "$HOME/.local/share/fcitx5/themes"
      rm -rf ./fcitx5
      echo "  ✓ Installed: catppuccin fcitx5 themes"
    fi
  fi

  echo "⚙️ bat のテーマを配置します..."
  if [ ! -d "$CONFIG_DIR/bat/themes/" ]; then
    mkdir -p "$CONFIG_DIR/bat/themes"
    curl -fsSL -o "$CONFIG_DIR/bat/themes/Catppuccin Mocha.tmTheme" \
      "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme"
    echo "  ✓ Installed: catppuccin bat themes"
  fi

  echo "🌳 nvim tree-sitter クエリを配置します..."
  install_nvim_ts_queries

  if [ "$OS_FAMILY" = "linux" ]; then
    echo "⚙️ keyd の設定を配置します..."
    if [ -d "$CONFIG_DIR/keyd" ]; then
      sudo mkdir -p /etc/keyd
      sudo ln -sf "$CONFIG_DIR/keyd/default.conf" /etc/keyd/default.conf
      echo "  ✓ Linked: /etc/keyd/default.conf"
    fi

    echo "⚙️ keyd サービスを有効化します..."
    sudo systemctl enable --now keyd
  fi

  if [ "$OS_FAMILY" = "macos" ]; then
    echo "⚙️ karabiner の設定を配置します..."
    mkdir -p "$CONFIG_DIR/karabiner"
    kbjson="$CONFIG_DIR/karabiner/karabiner.json"
    if [ -e "$kbjson" ] && [ ! -L "$kbjson" ]; then
      mv "$kbjson" "${kbjson}.backup"
    fi
    ln -snf "$DOTFILES_DIR/.config/karabiner/karabiner.json" "$kbjson"
    echo "  ✓ Linked: ~/.config/karabiner/karabiner.json"
    echo "  ℹ️ 初回はシステム設定で Karabiner に Input Monitoring /"
    echo "     アクセシビリティ権限を付与し、ドライバを有効化してください。"
  fi

  if [ "$OS_FAMILY" = "macos" ] && command -v rift > /dev/null 2>&1; then
    echo "⚙️ rift (タイリング WM) の設定を配置します..."
    mkdir -p "$CONFIG_DIR/rift"
    riftcfg="$CONFIG_DIR/rift/config.toml"
    if [ -e "$riftcfg" ] && [ ! -L "$riftcfg" ]; then
      mv "$riftcfg" "${riftcfg}.backup"
    fi
    ln -snf "$DOTFILES_DIR/.config/rift/config.toml" "$riftcfg"
    echo "  ✓ Linked: ~/.config/rift/config.toml"

    echo "⚙️ rift サービスを設定します..."
    rift service install
    rift service start
    rift service restart
    echo "  ℹ️ 初回はシステム設定でアクセシビリティ権限を付与してください。"
    echo "     権限付与後に 'rift service restart' を実行すると有効になります。"
  fi

  if [ "$OS_FAMILY" = "macos" ]; then
    echo "⚙️ macOS のシステム設定を適用します..."
    defaults write -g com.apple.keyboard.fnState -bool true
    echo "  ✓ fnState = true (ログアウト/再起動後に反映)"
  fi

  echo "⚙️ AIコミット生成スクリプトを配置します..."
  mkdir -p "$HOME/.local/bin"
  ln -snf "$DOTFILES_DIR/src/scripts/ai-commit-gen" "$HOME/.local/bin/ai-commit-gen"
  chmod +x "$DOTFILES_DIR/src/scripts/ai-commit-gen"
  echo "  ✓ Linked: ~/.local/bin/ai-commit-gen"

  echo "⚙️ herdr 用スクリプトを配置します..."
  for herdr_script in herdr-dev herdr-sessions; do
    ln -snf "$DOTFILES_DIR/src/scripts/$herdr_script" "$HOME/.local/bin/$herdr_script"
    chmod +x "$DOTFILES_DIR/src/scripts/$herdr_script"
    echo "  ✓ Linked: ~/.local/bin/$herdr_script"
  done

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
      local target="$dest/${file}.scm"
      if [ -f "$target" ]; then
        installed=$((installed + 1))
        continue
      fi
      local url="$base_url/nvim-treesitter-queries-${lang}/main/queries/${file}.scm"
      if curl -fsSL -o "$target" "$url" 2> /dev/null; then
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
    Darwin)
      install_packages_macos
      ;;
    *)
      echo "❌ 未対応のOSです: $OS"
      exit 1
      ;;
  esac

  fish_path="$(command -v fish)"
  if [ -n "$fish_path" ] && [ "$SHELL" != "$fish_path" ]; then
    echo "🐟 デフォルトシェルを fish に変更します..."
    if [ "$OS_FAMILY" = "macos" ]; then
      if ! grep -qx "$fish_path" /etc/shells; then
        echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
      fi
      chsh -s "$fish_path"
    else
      sudo chsh -s "$fish_path" "$USER"
    fi
  fi

  echo "✅ インストール完了！"
}

install_packages_macos() {
  if ! command -v brew > /dev/null 2>&1; then
    echo "🍺 Homebrew が見つかりません。インストールします..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  echo "📦 Homebrew formulae をインストールします..."
  for pkg in "${MAC_PACKAGES[@]}"; do
    if brew install "$pkg"; then
      echo "  ✓ $pkg"
    else
      echo "  ⚠️ スキップ (失敗): $pkg"
    fi
  done

  echo "🖥️ Homebrew cask をインストールします..."
  for cask in "${MAC_CASKS[@]}"; do
    if brew install --cask --adopt "$cask"; then
      echo "  ✓ $cask"
    else
      echo "  ⚠️ スキップ (失敗): $cask"
    fi
  done
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
