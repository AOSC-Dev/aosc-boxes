#!/bin/bash
# shellcheck disable=SC2034,SC2154
IMAGE_NAME="AOSC-OS-${AOSC_ARCH}-cloudimg-debug-${build_version}.qcow2"
DISK_SIZE="16G"
PACKAGES=(cloud-utils)

function pre() {
  local NEWUSER="aosc"
  arch-chroot "${MOUNT}" /usr/bin/useradd -m -U "${NEWUSER}"
  echo -e "${NEWUSER}\n${NEWUSER}" | arch-chroot "${MOUNT}" /usr/bin/passwd "${NEWUSER}"
  echo "${NEWUSER} ALL=(ALL) NOPASSWD: ALL" >"${MOUNT}/etc/sudoers.d/${NEWUSER}"
  sed -Ei 's/^(GRUB_CMDLINE_LINUX_DEFAULT=.*)"$/\1 console=tty0 console=ttyS0,115200"/' "${MOUNT}/etc/default/grub"
  echo 'GRUB_TERMINAL="serial console"' >>"${MOUNT}/etc/default/grub"
  echo 'GRUB_SERIAL_COMMAND="serial --speed=115200"' >>"${MOUNT}/etc/default/grub"
  arch-chroot "${MOUNT}" /usr/bin/grub-mkconfig -o /boot/grub/grub.cfg
  # cloud-init topic
  export cloud_init_topic=$(curl https://repo.aosc.io/debs/manifest/topics.json | jq '.[] | select(.name | test("^cloud-init.*"))' | jq -r -s 'max_by(.name) | .name')
  if [ "${cloud_init_topic}" != "null" ] && [ ! -z "${cloud_init_topic}" ]; then
    arch-chroot "${MOUNT}" /usr/bin/oma topics --no-check-dbus --opt-in "${cloud_init_topic}"
  fi 

  arch-chroot ${MOUNT} /usr/bin/oma install -y --no-check-dbus cloud-init
  # add cloud-init services to cloud-init.preset
  cloud_init_services=(cloud-init-main.service cloud-init-network.service cloud-init-local.service cloud-config.service cloud-final.service)
  for service in "${cloud_init_services[@]}"; do
    echo "enable ${service}" >> "${MOUNT}/usr/lib/systemd/system-preset/50-cloud-init.preset"
  done
}

function post() {
  qemu-img convert -c -f raw -O qcow2 "${1}" "${2}"
  rm "${1}"
}
