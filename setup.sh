#!/bin/bash

# --- Arch Linux Post-Install Automation Script ---
# Description: Automated setup for Niri + DMS on Arch Linux
# Author: Aris
# Note: DO NOT run with sudo. Run as: ./setup.sh

set -e

# --- PRE-FLIGHT CHECKS ---
echo "--- Checking System State ---"

# 1. Prevent running as root/sudo directly
if [[ $EUID -eq 0 ]]; then
   echo "CRITICAL: Please run this script as a normal user, NOT root/sudo."
   exit 1
fi

# 2. Check for Internet
if ! ping -c 1 google.com &> /dev/null; then
    echo "ERROR: No internet connection."
    exit 1
fi

# 3. Helper function for Paru (ensure it never runs as root)
run_paru() {
    paru --needed --noconfirm "$@"
}

# --- STEP 1: XDG Dirs ---
echo "Step 1: XDG Directories..."
sudo pacman -S --needed --noconfirm xdg-user-dirs
xdg-user-dirs-update

# --- STEP 2: Paru Installation ---
if ! command -v paru &> /dev/null; then
    echo "Step 2: Installing Paru..."
    sudo pacman -S --needed --noconfirm base-devel git
    _tempdir=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$_tempdir"
    cd "$_tempdir" && makepkg -si --noconfirm
    cd - && rm -rf "$_tempdir"
fi

# --- STEP 3: Core Packages ---
echo "Step 3: Installing DMS, Niri, and Tools..."
run_paru nano brightnessctl quickshell cava cliphist wl-clipboard \
    dgop dsearch matugen niri qt6-multimedia polkit-gnome \
    dms-shell-bin greetd-dms-greeter-git kitty totem loupe \
    wf-recorder gst-plugins-good gst-plugins-bad gst-plugins-ugly \
    gst-libav ffmpegthumbnailer samba podman-compose

# --- STEP 4: DMS Setup (The Critical Part) ---
echo "Step 4: Configuring DMS..."

# Fix potential permission issues in ~/.config before running dms
sudo chown -R $USER:$USER "$HOME/.config" 2>/dev/null || true

# Explicitly run dms setup as user with clean environment
# We use 'env' to ensure no sudo-related variables leak in
env -u SUDO_USER -u SUDO_COMMAND -u SUDO_GID -u SUDO_UID dms setup

# Greetd Configuration (Needs Sudo)
echo "Configuring Greetd..."
sudo mkdir -p /etc/greetd
sudo bash -c 'cat <<EOF > /etc/greetd/config.toml
[terminal]
vt = 1

[default_session]
user = "greeter"
command = "dms-greeter --command niri"
EOF'

sudo dms greeter enable
dms greeter sync
sudo systemctl enable greetd

# --- STEP 5-7: Apps & Fonts ---
echo "Step 5-7: Fonts & Productivity Apps..."
run_paru noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-font-awesome \
    krita gimp inkscape google-chrome visual-studio-code-bin

# --- STEP 8: Wallpapers ---
if [ ! -d "$HOME/Pictures/Wallpapers" ]; then
    read -p "Clone ML4W Wallpapers? (y/N): " confirm_wp
    [[ "$confirm_wp" =~ ^[Yy]$ ]] && git clone https://github.com/mylinuxforwork/wallpaper "$HOME/Pictures/Wallpapers"
fi

# --- STEP 9: Dotfiles Sync ---
echo "Step 9: Syncing Dotfiles..."
TOP_LEVEL_DIRS=(".config" ".local" "Documents")
for dir in "${TOP_LEVEL_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        mkdir -p "$HOME/$(dirname "$dir")"
        cp -aux "$dir" "$HOME/" # -u only copies if source is newer
    fi
done

# --- STEP 10: Finalizing Shell ---
echo "Step 10: Finalizing Shell..."
run_paru fish

if [[ "$SHELL" != "/usr/bin/fish" ]]; then
    sudo usermod -s /usr/bin/fish $USER
fi

echo "----------------------------------------------------"
echo "Done! Please reboot to enter your new environment."
echo "----------------------------------------------------"
