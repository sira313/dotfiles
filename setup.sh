#!/bin/bash

# --- Arch Linux Post-Install Automation Script ---
# Description: Automated setup for Niri + DMS on Arch Linux
# Author: Aris

set -e

echo "--- Starting Post-Install Setup ---"

# 1. Setup Home Directories
echo "Step 1: Setting up XDG user directories..."
sudo pacman -S --noconfirm xdg-user-dirs
xdg-user-dirs-update

# 2. Install Paru (AUR Helper)
echo "Step 2: Installing Paru..."
sudo pacman -S --needed --noconfirm base-devel git
if ! command -v paru &> /dev/null; then
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
fi

# 3. Install DMS and Core Components
echo "Step 3: Installing DMS, Niri, and multimedia tools..."
paru -S --noconfirm \
    nano brightnessctl quickshell cava cliphist wl-clipboard \
    dgop dsearch matugen niri qt6-multimedia polkit-gnome \
    dms-shell-bin greetd-dms-greeter-git kitty totem loupe \
    wf-recorder gst-plugins-good gst-plugins-bad gst-plugins-ugly \
    gst-libav ffmpegthumbnailer samba podman-compose

# 4. Configure DMS & Greetd
echo "Step 4: Configuring DMS and Greetd..."
dms setup

# Create greetd config
sudo mkdir -p /etc/greetd
sudo bash -c 'cat <<EOF > /etc/greetd/config.toml
[terminal]
vt = 1

[default_session]
user = "greeter"
command = "dms-greeter --command niri"
EOF'

# Enable Greeter
sudo dms greeter enable
dms greeter sync
sudo systemctl enable greetd

# 5. Install Fonts
echo "Step 5: Installing fonts..."
paru -S --noconfirm noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-font-awesome

# 6. User Personalization & Shell
echo "Step 6: User Personalization..."

# Input full name from terminal
read -p "Enter your full name for this system: " full_name
sudo chfn -f "$full_name" $(whoami)

# Install and set Fish Shell
echo "Installing Fish Shell..."
paru -S --noconfirm fish
echo "Switching default shell to Fish..."
sudo chsh -s /usr/bin/fish $(whoami)

# 7. Applications
echo "Step 7: Installing productivity apps..."
paru -S --noconfirm krita gimp inkscape google-chrome visual-studio-code-bin

# 8. Wallpapers
echo "Step 8: Wallpapers..."
read -p "Apakah Anda ingin melakukan git clone untuk wallpaper dari ML4W? (y/N): " confirm_wallpaper

if [[ "$confirm_wallpaper" =~ ^[Yy]$ ]]; then
    if [ ! -d "$HOME/Pictures/Wallpapers" ]; then
        echo "Sedang mengunduh wallpaper..."
        mkdir -p "$HOME/Pictures"
        git clone https://github.com/mylinuxforwork/wallpaper "$HOME/Pictures/Wallpapers"
    else
        echo "Direktori wallpaper sudah ada, melewati langkah ini."
    fi
else
    echo "Melewati instalasi wallpaper."
fi

# --- Step 9: Sync Dotfiles (Place Files and Folders) ---
echo "Step 9: Menempatkan file konfigurasi ke folder tujuan..."

# Fungsi internal untuk menangani pengecekan folder dan replace file
deploy_file() {
    local src="$1"
    local dest_dir="$2"
    
    # mkdir -p akan skip jika folder sudah ada, dan membuat jika belum ada
    mkdir -p "$dest_dir"
    
    # Copy file (otomatis replace jika sudah ada)
    if [ -f "$src" ]; then
        cp "$src" "$dest_dir/"
        echo "[OK] $src -> $dest_dir"
    else
        echo "[SKIP] File $src tidak ditemukan di folder repository"
    fi
}

# Eksekusi penempatan sesuai directory tree
deploy_file ".config/fastfetch/config.jsonrc" "$HOME/.config/fastfetch"
deploy_file ".config/fish/config.fish" "$HOME/.config/fish"
deploy_file ".config/fish/functions/share-off.fish" "$HOME/.config/fish/functions"
deploy_file ".config/fish/functions/share-on.fish" "$HOME/.config/fish/functions"
deploy_file ".config/fish/functions/start-win.fish" "$HOME/.config/fish/functions"
deploy_file ".config/kitty/kitty.conf" "$HOME/.config/kitty"
deploy_file ".config/niri/config.kdl" "$HOME/.config/niri"
deploy_file ".config/niri/dms/binds.kdl" "$HOME/.config/niri/dms"
deploy_file "Documents/windows11/podman-compose.yml" "$HOME/Documents/windows11"
deploy_file ".local/share/applications/win-start.desktop" "$HOME/.local/share/applications"
deploy_file ".local/share/applications/win-stop.desktop" "$HOME/.local/share/applications"

# Memberikan izin eksekusi pada fungsi fish agar terbaca oleh shell
chmod +x $HOME/.config/fish/functions/*.fish 2>/dev/null

echo "Step 9 selesai!"

echo "----------------------------------------------------"
echo "Setup Complete! System is ready."
echo "Please reboot to apply all changes and enter DMS."
echo "----------------------------------------------------"
