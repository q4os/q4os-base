#!/bin/sh
#Make the firmware fallback boot path \EFI\BOOT\BOOTX64.EFI start this system, as root, on the installed system.
#A firmware that forgets its boot entries (flat CMOS battery, BIOS reset, firmware update) starts that file. The live
#installer puts there a copy of the signed grubx64.efi alone, which fails twice:
# - the signed grub reads grub.cfg from the directory it was started from, then from its built-in /EFI/debian
#   (/EFI/ubuntu); neither holds one, so the machine stops at a grub prompt;
# - with Secure Boot enabled the firmware refuses it ("Access Denied"): only shim verifies the distro-signed grub.
#So lay the fallback out as Debian's "grub-install --force-extra-removable" does (shim as BOOTX64.EFI, grubx64.efi,
#mmx64.efi), add the grub.cfg stub that option leaves out, and set grub2/force_efi_extra_removable so grub and shim
#upgrades keep the fallback current (a stale signed grub there could later be revoked through SBAT).
#Takes over only a fallback that already holds a grub, never a grub.cfg written by another system. Idempotent.

ESP1="/boot/efi/EFI"
FB1="$ESP1/BOOT" #FAT: matches EFI/boot as well
UUID1="$( findmnt -n -o UUID -T /boot 2>/dev/null )"
[ -n "$UUID1" ] && [ -f "$FB1/BOOTX64.EFI" ] || exit 0
grep -q -s -a "GNU GRUB" "$FB1/BOOTX64.EFI" "$FB1/grubx64.efi" || exit 0 #not a grub, e.g. Windows Boot Manager

#this system's own directory: the one whose stub points to this system's /boot
VDIR1=""
for DIR1 in "$ESP1"/* ; do
  case "${DIR1##*/}" in [Bb][Oo][Oo][Tt]) continue ;; esac
  if [ -f "$DIR1/grub.cfg" ] && grep -q "$UUID1" "$DIR1/grub.cfg" ; then
    VDIR1="$DIR1"
    break
  fi
done
[ -n "$VDIR1" ] || exit 0 #no stub: an unsigned grub, which carries its own prefix and boots from the fallback as is

if [ -f "$FB1/grub.cfg" ] && ! cmp -s "$FB1/grub.cfg" "$VDIR1/grub.cfg" ; then
  echo "EFI fallback: $FB1/grub.cfg belongs to another system, left as is."
  exit 0
fi

CHG1=""
if ! cmp -s "$VDIR1/grub.cfg" "$FB1/grub.cfg" ; then
  cp "$VDIR1/grub.cfg" "$FB1/grub.cfg" && CHG1="1"
fi
if [ -f "$VDIR1/shimx64.efi" ] && [ -f "$VDIR1/grubx64.efi" ] ; then
  #BOOTX64.EFI goes last: until it is replaced the old fallback keeps working
  for FL1 in grubx64.efi mmx64.efi shimx64.efi ; do
    [ -f "$VDIR1/$FL1" ] || continue
    TG1="$FL1" ; [ "$FL1" = "shimx64.efi" ] && TG1="BOOTX64.EFI"
    if ! cmp -s "$VDIR1/$FL1" "$FB1/$TG1" ; then
      cp "$VDIR1/$FL1" "$FB1/$TG1.tmp" && mv -f "$FB1/$TG1.tmp" "$FB1/$TG1" && CHG1="1"
    fi
  done
  echo "grub-efi-amd64 grub2/force_efi_extra_removable boolean true" | debconf-set-selections 2>/dev/null || true
fi
[ -n "$CHG1" ] && echo "EFI fallback boot path updated from ${VDIR1##*/}."
exit 0
