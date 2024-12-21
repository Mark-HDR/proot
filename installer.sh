#!/bin/sh

ROOTFS_DIR=$(pwd)
ARCH=$(uname -m)
export PATH=$PATH:~/.local/usr/bin
MAX_RETRIES=50
TIMEOUT=1

# Tentukan nama arsitektur untuk digunakan di URL
case "$ARCH" in
  x86_64) ARCH_ALT="x86_64" ;;
  aarch64) ARCH_ALT="aarch64" ;;
  *) echo "Unsupported CPU architecture: ${ARCH}" && exit 1 ;;
esac

clear
echo -e "\e[0;36m###########################################################\e[0m"
echo -e "\e[0;32m#                 Mark-HDR Installer                    #\e[0m"
echo -e "\e[0;32m#          Copyright (C) 2024, hexel-cloud.com         #\e[0m"
echo -e "\e[0;36m###########################################################\e[0m"
echo -e "\e[1;33m                                                           \e[0m"
echo -e "\e[1;34m     Welcome to the ultimate Mark-HDR Installer! \e[0m"
echo -e "\e[1;32m   Installing Ubuntu Base and PRoot in style... \e[0m"
echo -e "\e[1;33m    Please follow the instructions below. Let’s GO!   \e[0m"
echo -e "\e[1;36m-----------------------------------------------------------\e[0m"
echo -e "\e[0;32m      .----.        .-----\e[0m"
echo -e "\e[0;32m     /      \       /     \ \e[0m"
echo -e "\e[0;32m    |        |     |       | \e[0m"
echo -e "\e[0;32m     \      /       \     /  \e[0m"
echo -e "\e[0;32m      '----'         '-----'  \e[0m"
echo -e "\e[0;36m-----------------------------------------------------------\e[0m"
echo ""

# Meminta konfirmasi untuk menginstal Ubuntu
read -p "Do you want to install Ubuntu? (YES/no): " install_ubuntu

if [[ "$install_ubuntu" =~ ^[yY][eE][sS]$ ]]; then
  echo -e "\e[0;32m\nDownloading Ubuntu Base Image...\e[0m"
  wget --tries=$MAX_RETRIES --timeout=$TIMEOUT --no-hsts -O /tmp/rootfs.tar.gz \
    "http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/ubuntu-base-20.04.4-base-${ARCH_ALT}.tar.gz"
  echo -e "\e[0;33m\nExtracting Ubuntu Base...\e[0m"
  tar -xf /tmp/rootfs.tar.gz -C "$ROOTFS_DIR"
else
  echo -e "\e[0;31m\nSkipping Ubuntu installation...\e[0m"
fi

echo -e "\e[0;32m\nSetting up PRoot...\e[0m"
mkdir -p "$ROOTFS_DIR/usr/local/bin"
wget --tries=$MAX_RETRIES --timeout=$TIMEOUT --no-hsts -O "$ROOTFS_DIR/usr/local/bin/proot" \
  "https://raw.githubusercontent.com/Mark-HDR/proot/${ARCH_ALT}/proot-${ARCH}"

while [ ! -s "$ROOTFS_DIR/usr/local/bin/proot" ]; do
  rm -f "$ROOTFS_DIR/usr/local/bin/proot"
  wget --tries=$MAX_RETRIES --timeout=$TIMEOUT --no-hsts -O "$ROOTFS_DIR/usr/local/bin/proot" \
    "https://raw.githubusercontent.com/Mark-HDR/proot/${ARCH_ALT}/proot-${ARCH}"
  sleep 1
done

chmod 755 "$ROOTFS_DIR/usr/local/bin/proot"
echo -e "nameserver 1.1.1.1\nnameserver 1.0.0.1" > "$ROOTFS_DIR/etc/resolv.conf"
touch "$ROOTFS_DIR/.installed"

clear
echo -e "\e[0;36m###########################################################\e[0m"
echo -e "\e[0;32m#                     Mission Completed!               #\e[0m"
echo -e "\e[0;32m#          Copyright (C) 2024, hexel-cloud.com         #\e[0m"
echo -e "\e[0;36m###########################################################\e[0m"
echo ""
echo -e "\e[1;32m           >>> Installation Successful! <<< \e[0m"
echo -e "\e[1;36m      Now running PRoot with the root filesystem...\e[0m"
echo ""
echo -e "\e[1;33m-----------------------------------------------------------\e[0m"
echo -e "\e[1;32m   Starting PRoot... Please wait...\e[0m"
echo -e "\e[1;33m   This may take a few moments...\e[0m"
echo -e "\e[1;36m-----------------------------------------------------------\e[0m"

"$ROOTFS_DIR/usr/local/bin/proot" --rootfs="$ROOTFS_DIR" -0 -w "/root" -b /dev -b /sys -b /proc -b /etc/resolv.conf --kill-on-exit

