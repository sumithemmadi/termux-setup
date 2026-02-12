#!/usr/bin/env bash

set -e  # Exit immediately if a command fails

# ===== Ensure running in Termux =====
if [ ! -d "/data/data/com.termux/files/usr" ]; then
    echo "This script is intended to run only in Termux. Exiting..."
    exit 1
fi

echo "Running in Termux ✓"

# ===== Detect package manager =====
if command -v pacman >/dev/null 2>&1; then
    PACKAGE_MANAGER="pacman"
elif command -v apt >/dev/null 2>&1; then
    PACKAGE_MANAGER="apt"
else
    echo "No supported package manager (pacman or apt) found. Exiting..."
    exit 1
fi

echo "Using $PACKAGE_MANAGER package manager."

# ===== Update & Upgrade system =====
echo "Updating and upgrading system..."

if [ "$PACKAGE_MANAGER" = "pacman" ]; then
    pacman -Syu --noconfirm
elif [ "$PACKAGE_MANAGER" = "apt" ]; then
    apt update -y
    apt upgrade -y
fi

echo "System update complete ✓"

# ===== Install required packages =====
packages="zsh zsh-completions sudo less curl wget git neofetch"

install_package() {
    local pkg=$1
    if [ "$PACKAGE_MANAGER" = "pacman" ]; then
        if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
            echo "Installing $pkg..."
            pacman -S --noconfirm "$pkg"
        else
            echo "$pkg already installed ✓"
        fi
    elif [ "$PACKAGE_MANAGER" = "apt" ]; then
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            echo "Installing $pkg..."
            apt install -y "$pkg"
        else
            echo "$pkg already installed ✓"
        fi
    fi
}

for pkg in $packages; do
    install_package "$pkg"
done

echo "All packages checked ✓"

# ===== Create directories =====
mkdir -p "$HOME/.zsh"
mkdir -p "$HOME/.suroot"

# ===== Download fresh .zshrc =====
echo "Downloading fresh .zshrc..."
wget -q -O "$HOME/.zshrc" https://grml.org/console/zshrc

# ===== Clone plugins safely =====
if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git \
        "$HOME/.zsh/zsh-autosuggestions"
fi

if [ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$HOME/.zsh/zsh-syntax-highlighting"
fi

# ===== Add plugins to .zshrc safely =====
if ! grep -q "zsh-autosuggestions.zsh" "/data/data/com.termux/files/home/.zshrc"; then
    echo "source /data/data/com.termux/files/home/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "/data/data/com.termux/files/home/.zshrc"
fi

if ! grep -q "zsh-syntax-highlighting.zsh" "/data/data/com.termux/files/home/.zshrc"; then
    echo "source /data/data/com.termux/files/home/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "/data/data/com.termux/files/home/.zshrc"
fi

# ===== Copy .zshrc to .suroot =====
cp "$HOME/.zshrc" "$HOME/.suroot/.zshrc"


# ===== Append neofetch ONLY to home .zshrc =====
if ! grep -q "neofetch --ascii_distro arch_small" "$HOME/.zshrc"; then
    echo "neofetch --ascii_distro arch_small" >> "$HOME/.zshrc"
fi

# ===== Change default shell to zsh =====
if command -v chsh >/dev/null 2>&1; then
    if [ "$SHELL" != "$(command -v zsh)" ]; then
        echo "Changing default shell to zsh..."
        chsh -s zsh
    else
        echo "Default shell already set to zsh ✓"
    fi
else
    echo "chsh not available. You may need to set zsh manually."
fi

# ===== Remove motd files =====
find /data/data/com.termux/files/usr/etc/ -type f -name 'motd*' -exec rm -f {} \; 2>/dev/null || true

echo ""
echo "Setup completed successfully! 🎉"
echo "Restart Termux to start using zsh."
