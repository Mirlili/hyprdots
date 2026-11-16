#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

if [[ "${EUID}" -eq 0 ]]; then
    echo "Ошибка: запустите установщик от обычного пользователя; sudo он вызовет сам." >&2
    exit 1
elif command -v sudo >/dev/null 2>&1; then
    SUDO=(sudo)
else
    echo "Ошибка: нужен sudo для установки системных пакетов." >&2
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "Ошибка: этот установщик рассчитан на Arch Linux и pacman." >&2
    exit 1
fi

if [[ ! -d "$SCRIPT_DIR/.config" ]]; then
    echo "Ошибка: рядом с install.sh не найдена папка .config." >&2
    exit 1
fi

echo "==> Установка официальных пакетов..."
"${SUDO[@]}" pacman -Syu --needed --noconfirm \
    kitty dolphin hyprland neovim wofi firefox swaybg zsh curl git neofetch \
    brightnessctl playerctl cliphist wl-clipboard

echo "==> Установка пакетов из AUR..."
aur_helper=""
if command -v yay >/dev/null 2>&1; then
    aur_helper="yay"
elif command -v paru >/dev/null 2>&1; then
    aur_helper="paru"
fi

if [[ -n "$aur_helper" ]]; then
    "$aur_helper" -S --needed --noconfirm spotify ironbar-git hyprshot
else
    echo "Внимание: yay/paru не найден; пропускаю AUR-пакеты: spotify, ironbar-git, hyprshot." >&2
fi

echo "==> Установка Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    KEEP_ZSHRC=yes RUNZSH=no CHSH=no \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended
else
    echo "Oh My Zsh уже установлен, пропускаю."
fi

echo "==> Установка конфигов и обоев..."
mkdir -p "$CONFIG_DIR" "$WALLPAPER_DIR"
cp -a "$SCRIPT_DIR/.config/." "$CONFIG_DIR/"
install -m 0644 "$SCRIPT_DIR/wallpaper.jpg" "$WALLPAPER_DIR/wallpaper.jpg"

echo "==> Готово! Перезапустите Hyprland, чтобы применить конфигурацию."
