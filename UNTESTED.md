# Untested changes

Install-test each item, then delete it; delete this file when it is empty.

- 4.31.20-a1 (2026-10-16, a34): `efi_fallback_boot.sh`, run from the postinst on upgrade and by the live
  installer's hook3. VERIFIED on an installed Q4OS 6.10 TDE r2 (trixie, amd64, Secure Boot shim layout): run as
  root it puts shim, grub, mmx64 and the grub.cfg stub into `EFI/BOOT` and sets
  `grub2/force_efi_extra_removable`; a second run changes nothing; `dpkg-reconfigure grub-efi-amd64` afterwards
  refreshes the fallback and keeps the stub; a system where the owner had copied only grub.cfg by hand is
  completed the same way; with a blank OVMF varstore the system boots to the login screen, Secure Boot off and
  enforcing (before: grub prompt, and "Access Denied"). A stale stub of an earlier system in `EFI/BOOT` is left
  as is without `--installer` (the fallback stays untouched) and replaced with it; the replaced one boots with a
  blank varstore under Secure Boot.
  Not verified: the built .deb and its postinst under a real `apt full-upgrade` (the script was run directly),
  Quark (Ubuntu), Q4OS 5 / 7, i386 / arm64 (the script handles only BOOTX64.EFI and does nothing elsewhere), an
  ESP shared with Windows or another Linux, an unsigned-grub install, real hardware.
