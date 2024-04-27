#!/bin/bash

# This script is to install the required packages for the arch linux system

# Update the system
echo "Updating the system"
sudo pacman -Syu 


# Autoclean the pacman cache
echo "Autocleaning the pacman cache"
sudo pacman -S --needed pacman-contrib
sudo systemctl enable paccache.timer

# Install reflector package to get the fastest mirror

echo "Installing reflector package"
sudo pacman -S --noconfirm --needed reflector

sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

# Get the fastest mirror
echo "Getting the fastest mirror"
sudo reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Update the system
echo "Updating the system"
sudo pacman -Syu

# Install bluetooth packages if the system has bluetooth adapter
if hciconfig | grep -q "hci"; then
    echo "Bluetooth adapter found"
    sudo pacman -S --noconfirm --needed bluez bluez-utils blueman
    sudo systemctl enable bluetooth.service
    sudo systemctl start bluetooth.service
else
    echo "Bluetooth adapter not found"
fi


# Install essential packages
echo "Installing essential packages"

sudo pacman -S --noconfirm --needed vim neovim nano unrar unzip p7zip wget curl neofetch htop linux-lts-headers

# Install java jdk

echo "Installing java jdk"
sudo pacman -S --noconfirm --needed jdk-openjdk

# Install the drivers for the system
echo "Installing the drivers"

cpu_model=$(lscpu | grep "Model name" | awk -F': ' '{print $2}')

if echo "$cpu_model" | grep -q "Intel"; then
    echo "Intel CPU found, downloading the drivers..."
    sudo pacman -S --noconfirm --needed intel-ucode
elif echo "$cpu_model" | grep -q "AMD"; then
    echo "AMD CPU found, downloading the drivers..."
    sudo pacman -S --noconfirm --needed amd-ucode
else
    echo "No drivers found for the CPU"
fi



# Update the system, if the bootloader is grub or systemd-boot
echo "Updating the system"
if [ -f "/boot/grub/grub.cfg" ]; then
    echo "Updating the grub configuration"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

if [ -d "/boot/loader" ] && [ -f "/boot/loader/loader.conf" ]; then
    echo "Updating the systemd-boot configuration"
    sudo bootctl update
fi


# Install yay package manager
echo "Installing yay package manager"

pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# Install the packages from the AUR
echo "Installing packages from the AUR"
yay -S --noconfirm  auto-cpufreq preload

# Enable the auto-cpufreq service
echo "Enabling the auto-cpufreq service"
sudo systemctl enable auto-cpufreq
sudo systemctl start auto-cpufreq


echo "Preload package installed, enabling the service"
sudo systemctl enable preload
sudo systemctl start preload

# install another packages
echo "Installing another packages"
sudo pacman -S --noconfirm --needed flatpak vlc ufw timeshift chromium dbeaver virtualbox virtualbox-host-dkms

# Enable the ufw firewall
echo "Enabling the ufw firewall"
sudo sytemctl enable ufw
sudo systemctl start ufw

# Enable the timeshift service
echo "Enabling the timeshift service"
sudo systemctl enable timeshift

# install flatpak packages
echo "Installing flatpak packages"

flatpak install flathub org.duckstation.DuckStation

#Install fnm and nodejs

echo "Installing fnm and nodejs"

echo "Installing Rust Lang"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "Installing fnm"
curl -fsSL https://fnm.vercel.app/install | bash

echo "Installing nodejs"
fnm install --lts

# Installing fonts

sudo pacman -S --noconfirm --needed ttf-cascadia-code ttf-dejavu ttf-ms-fonts ttf-linux-libertine noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra
yay -S --noconfirm ttf-ms-fonts

# Downlod themes and icons
echo "Downloading themes and icons"

git clone https://github.com/vinceliuice/Orchis-theme.git

cd Orchis-theme && ./install.sh

cd ..

git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git

cd Tela-circle-icon-theme && ./install.sh

cd ..

git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git

cd WhiteSur-gtk-theme && ./install.sh

cd ..
