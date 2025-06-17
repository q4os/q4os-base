#!/bin/sh

# --- initialize ---
cd $(dirname $0)
MTIME1="2001-10-10"
SETUPDIR="$(pwd)"
OUTDIR1="$SETUPDIR/../_00_filesystem_built/"
OUTDIR2="$SETUPDIR/../_00_gettext/"
rm -rf $OUTDIR1 $OUTDIR2
mkdir -p $OUTDIR1 $OUTDIR2

# --- copy filesystem ---
cp -r $SETUPDIR/filesystem/* $OUTDIR1/

# --- update and copy kthemes ---
DESTDIR1="$OUTDIR1/opt/trinity/share/apps/kthememanager/themes/"
mkdir -p $DESTDIR1
cp -r $SETUPDIR/themes_ktheme/* $DESTDIR1/

# --- create home archives for kthemes ---
DESTDIR1="$OUTDIR1/opt/trinity/share/apps/kthememanager/themes/"
mkdir -p $DESTDIR1
SRCDIR1="$SETUPDIR/themes_homedir/"
DIRNM="q4os_default"
cd $SRCDIR1/$DIRNM
GZIP='-n' tar -c --mtime="$MTIME1" --owner="1000" --group="1000" --numeric-owner --sort=name -z -f $DESTDIR1/$DIRNM.tar.gz .

# --- copy initial ktheme helper ---
DESTDIR1="$OUTDIR1/usr/share/apps/q4os_system/share/"
mkdir -p $DESTDIR1
SRCDIR1="$SETUPDIR/themes_homedir/"
DIRNM="ktheme_init"
cd $SRCDIR1/$DIRNM
GZIP='-n' tar -c --mtime="$MTIME1" --owner="1000" --group="1000" --numeric-owner --sort=name -z -f $DESTDIR1/$DIRNM.tar.gz .

# --- pack q4os_home ---
cd $SETUPDIR/skelet_home/q4os_home
GZIP='-n' tar -c --mtime="$MTIME1" --owner="1000" --group="1000" --numeric-owner --sort=name -f $OUTDIR1/usr/share/apps/q4os_system/share/q4os_home.tar .
cd $SETUPDIR/skelet_home/q4os_devpack_home
GZIP='-n' tar -u --mtime="$MTIME1" --owner="1000" --group="1000" --numeric-owner --sort=name -f $OUTDIR1/usr/share/apps/q4os_system/share/q4os_home.tar .
cd $SETUPDIR/skelet_home/q4os_home_kde5
GZIP='-n' tar -u --mtime="$MTIME1" --owner="1000" --group="1000" --numeric-owner --sort=name -f $OUTDIR1/usr/share/apps/q4os_system/share/q4os_home.tar .
gzip -n $OUTDIR1/usr/share/apps/q4os_system/share/q4os_home.tar
cd $SETUPDIR/skelet_home/q4os_home_lxqt
GZIP='-n' tar -c --mtime="$MTIME1" --owner="1000" --group="1000" --numeric-owner --sort=name -f $OUTDIR1/usr/share/apps/q4os_system/share/q4os_home_bullseye.tar .
gzip -n $OUTDIR1/usr/share/apps/q4os_system/share/q4os_home_bullseye.tar
cd $OUTDIR1/usr/share/apps/q4os_system/share/
ln -s q4os_home_bullseye.tar.gz q4os_home_bookworm.tar.gz
ln -s q4os_home_bullseye.tar.gz q4os_home_trixie.tar.gz
ln -s q4os_home_bullseye.tar.gz q4os_home_raspbian12.tar.gz
ln -s q4os_home_bullseye.tar.gz q4os_home_focal.tar.gz
ln -s q4os_home_bullseye.tar.gz q4os_home_jammy.tar.gz
ln -s q4os_home_bullseye.tar.gz q4os_home_noble.tar.gz

# --- generate localization .po files ---
cd $OUTDIR1/
if [ -d "/mnt/tmsworkspace/q4os-4.0/a_my_files" ] ; then
  find . -iname "*.sh" -o -iname "addlanguage" -o -iname "qrepoadd" | xargs xgettext -L shell -s --no-wrap --package-name "q4os-base" -o $OUTDIR2/.q4os-base1.pot
  find /mnt/tmsworkspace/q4os-4.0/a_my_files/ -iname "*.sh" -o -iname "kwhksh" | xargs xgettext -L shell -s --no-wrap --package-name "q4os-base" -o $OUTDIR2/.q4os-base2.pot
  msgcat -u --no-location -s --no-wrap -o $OUTDIR2/q4os-base.pot $OUTDIR2/.q4os-base1.pot $OUTDIR2/.q4os-base2.pot
fi

# --- remove unneeded files ---
rm $OUTDIR1/usr/share/applications/todo.txt
rm $OUTDIR1/usr/share/apps/q4os_system/bin/.ctrl_wintiling_tde.sh.prepared
rm $OUTDIR1/usr/share/apps/q4os_system/bin/.is_mnt_crypted.sh.prepared
rm $OUTDIR1/usr/share/apps/q4os_system/bin/.watch_apt_busy.prepared
rm $OUTDIR1/usr/share/apps/q4os_system/bin/.watch_apt_reboot_required.prepared-todo
