#!/bin/sh

ROOTFS_DIR=$(pwd)
export PATH=$PATH:~/.local/usr/bin
max_retries=50
timeout=1
ARCH=$(uname -m)

# Tentukan arsitektur alternatif berdasarkan sistem
if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=amd64
  PROOT_URL="https://raw.githubusercontent.com/Mark-HDR/proot/ARCH/x86-64"
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=arm64
  PROOT_URL="https://raw.githubusercontent.com/Mark-HDR/proot/ARCH/aarch64"
else
  printf "Unsupported CPU architecture: ${ARCH}\n"
  exit 1
fi

# Cek apakah instalasi sebelumnya sudah ada
if [ ! -e $ROOTFS_DIR/.installed ]; then
  echo "#######################################################################################"
  echo "#"
  echo "#                                      Mark-HDR INSTALLER"
  echo "#"
  echo "#                           Copyright (C) 2024, hexel-cloud.com"
  echo "#"
  echo "#"
  echo "#######################################################################################"

  # Tanya pengguna apakah ingin menginstal Ubuntu
  read -p "Do you want to install Ubuntu? (YES/no): " install_ubuntu
fi

# Jika pengguna memilih untuk menginstal Ubuntu
case $install_ubuntu in
  [yY][eE][sS])
    echo "Downloading Ubuntu Base Image..."
    wget --tries=$max_retries --timeout=$timeout --no-hsts -O /tmp/rootfs.tar.gz \
      "http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/ubuntu-base-20.04.4-base-${ARCH_ALT}.tar.gz"
    tar -xf /tmp/rootfs.tar.gz -C $ROOTFS_DIR
    ;;
  *)
    echo "Skipping Ubuntu installation."
    ;;
esac

# Jika instalasi belum dilakukan, lakukan pengaturan lainnya
if [ ! -e $ROOTFS_DIR/.installed ]; then
  mkdir -p $ROOTFS_DIR/usr/local/bin
  echo "Downloading proot binary for ${ARCH}..."
  wget --tries=$max_retries --timeout=$timeout --no-hsts -O $ROOTFS_DIR/usr/local/bin/proot \
    "$PROOT_URL"

  # Cek apakah proot sudah terunduh dengan benar, jika tidak coba lagi
  while [ ! -s "$ROOTFS_DIR/usr/local/bin/proot" ]; do
    rm -rf $ROOTFS_DIR/usr/local/bin/proot
    echo "Retrying to download proot binary..."
    wget --tries=$max_retries --timeout=$timeout --no-hsts -O $ROOTFS_DIR/usr/local/bin/proot \
      "$PROOT_URL"

    # Cek apakah file berhasil terunduh dan atur permission
    if [ -s "$ROOTFS_DIR/usr/local/bin/proot" ]; then
      chmod 755 $ROOTFS_DIR/usr/local/bin/proot
      break
    fi

    sleep 1
  done

  chmod 755 $ROOTFS_DIR/usr/local/bin/proot
fi

# Atur DNS jika belum ada resolv.conf
if [ ! -e $ROOTFS_DIR/.installed ]; then
  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > ${ROOTFS_DIR}/etc/resolv.conf
  rm -rf /tmp/rootfs.tar.xz /tmp/sbin
  touch $ROOTFS_DIR/.installed
fi

# Warna untuk tampilan
CYAN='\e[0;36m'
WHITE='\e[0;37m'
RESET_COLOR='\e[0m'

# Fungsi untuk menampilkan pesan selesai
display_gg() {
  echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
  echo -e ""
  echo -e "           ${CYAN}-----> Mission Completed ! <----${RESET_COLOR}"
}

# Bersihkan layar dan tampilkan pesan selesai
clear
display_gg

# Jalankan proot untuk memasuki lingkungan baru
$ROOTFS_DIR/usr/local/bin/proot \
  --rootfs="${ROOTFS_DIR}" \
  -0 -w "/root" -b /dev -b /sys -b /proc -b /etc/resolv.conf --kill-on-exit
