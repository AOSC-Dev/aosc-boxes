#!/bin/bash
# shellcheck disable=SC2034,SC2154
IMAGE_NAME="AOSC-OS-x86_64-cloudimg-${build_version}.qcow2"
DISK_SIZE="15G"
PACKAGES=(cloud-init cloud-utils)
#TODO: for cloud-init 2024.3 and later, use cloud-init-main.service instead of cloud-init.service
# SERVICES=(cloud-init-main.service cloud-init-local.service cloud-init-network.service cloud-config.service cloud-final.service)
SERVICES=(cloud-init.service)

function pre() {
  sed -Ei 's/^(GRUB_CMDLINE_LINUX_DEFAULT=.*)"$/\1 console=tty0 console=ttyS0,115200"/' "${MOUNT}/etc/default/grub"
  echo 'GRUB_TERMINAL="serial console"' >>"${MOUNT}/etc/default/grub"
  echo 'GRUB_SERIAL_COMMAND="serial --speed=115200"' >>"${MOUNT}/etc/default/grub"
  arch-chroot "${MOUNT}" /usr/bin/grub-mkconfig -o /boot/grub/grub.cfg
}

function post() {
  qemu-img convert -c -f raw -O qcow2 "${1}" "${2}"
  rm "${1}"
}
