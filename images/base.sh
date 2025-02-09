#!/bin/bash

# Misc "tweaks" done after bootstrapping
function pre() {
  # Remove machine-id see:
  # https://gitlab.archlinux.org/archlinux/arch-boxes/-/issues/25
  # https://gitlab.archlinux.org/archlinux/arch-boxes/-/issues/117
  rm "${MOUNT}/etc/machine-id"

  echo "build_version: $build_version" >> "${MOUNT}/etc/aosc-image.info"
  echo "build_time: $(date)" >> "${MOUNT}/etc/aosc-image.info"

  arch-chroot "${MOUNT}" /usr/bin/systemd-firstboot --locale=C.UTF-8 --timezone=UTC --hostname=aosc --keymap=us
  systemctl --root=${MOUNT} enable sshd NetworkManager systemd-timesyncd

  # GRUB
  arch-chroot "${MOUNT}" /usr/bin/grub-install --target=i386-pc "${LOOPDEV}"
  arch-chroot "${MOUNT}" /usr/bin/grub-install --target=x86_64-efi --efi-directory=/efi --removable
  sed -i 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=1/' "${MOUNT}/etc/default/grub"
  # setup unpredictable kernel names
  sed -i 's/^GRUB_CMDLINE_LINUX=.*$/GRUB_CMDLINE_LINUX="net.ifnames=0"/' "${MOUNT}/etc/default/grub"
  arch-chroot "${MOUNT}" /usr/bin/grub-mkconfig -o /boot/grub/grub.cfg
  # set systemd default target to multi-user
  ln -sf /usr/lib/systemd/system/multi-user.target "${MOUNT}/etc/systemd/system/default.target"
}
