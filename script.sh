#!/bin/bash

# This script is to install the required packages for the arch linux system

# Update the system
echo "Updating the system"
sudo pacman -Syu 

# configure the pacman.conf file

echo "Configuring the pacman.conf file"
# Uncomment the color line in pacman.conf
sed -i "/^#Color/{s/^#//; n;n;n;n;s/^$/\n/}" /etc/pacman.conf

echo "Pacman configuration done"

# Autoclean the pacman cache
echo "Autocleaning the pacman cache"
sudo pacman -S pacman-contrib
sudo systemctl enable paccache.timer

# Install reflector package to get the fastest mirror

echo "Installing reflector package"
sudo pacman -S --noconfirm reflector

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
    sudo pacman -S --noconfirm bluez bluez-utils blueman
    sudo systemctl enable bluetooth.service
    sudo systemctl start bluetooth.service
else
    echo "Bluetooth adapter not found"
fi


# Install essential packages
echo "Installing essential packages"

sudo pacman -S --noconfirm vim nano unrar unzip p7zip wget curl neofetch htop 

# Install java jdk

echo "Installing java jdk"
sudo pacman -S --noconfirm jdk-openjdk

# Install the drivers for the system
echo "Installing the drivers"

cpu_model=$(lscpu | grep "Model name" | awk -F': ' '{print $2}')

if echo "$cpu_model" | grep -q "Intel"; then
    echo "Intel CPU found, downloading the drivers..."
    sudo pacman -S --noconfirm intel-ucode
elif echo "$cpu_model" | grep -q "AMD"; then
    echo "AMD CPU found, downloading the drivers..."
    sudo pacman -S --noconfirm amd-ucode
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
yay -S --noconfirm google-chrome visual-studio-code-bin 

# install another packages
echo "Installing another packages"
sudo pacman -S --noconfirm flatpak vlc ufw timeshift 

# Enable the ufw firewall
echo "Enabling the ufw firewall"
sudo sytemctl enable ufw
sudo systemctl start ufw

# Install preload package

echo "Installing the preload package"
yay -S --noconfirm preload
echo "Preload package installed, enabling the service"
sudo systemctl enable preload
sudo systemctl start preload

