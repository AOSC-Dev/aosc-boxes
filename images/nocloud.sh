#!/bin/bash
# shellcheck disable=SC2034,SC2154
IMAGE_NAME="AOSC-OS-${AOSC_ARCH}-nocloud-${build_version}.qcow2"
DISK_SIZE="16G"
PACKAGES=(qemu-guest-agent)
SERVICES=()

function pre() {
  local NEWUSER="aosc"
  arch-chroot "${MOUNT}" /usr/bin/useradd -m -U "${NEWUSER}"
  echo -e "${NEWUSER}\n${NEWUSER}" | arch-chroot "${MOUNT}" /usr/bin/passwd "${NEWUSER}"
  echo "${NEWUSER} ALL=(ALL) NOPASSWD: ALL" >"${MOUNT}/etc/sudoers.d/${NEWUSER}"
}

function post() {
  qemu-img convert -c -f raw -O qcow2 "${1}" "${2}"
  rm "${1}"
}
