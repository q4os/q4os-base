#!/bin/sh

if [ -f "/var/lib/q4os/first_boot_script_done.stp" ] ; then
  echo "This script has been already ran, exiting ..."
  systemctl disable q4os_first_boot.service
  exit
fi

echo "\n>> Q4OS first boot script started: $( date +%Y-%m-%d-%H-%M-%S ) <<"

TDEHOME="/root/.trinity" #for kreadconfig not to write to user's homedir
SYSTEM_INSTALL="$( /opt/trinity/bin/kreadconfig --file "/etc/q4os/q4base.conf" --group "OnInstall" --key "install_type" )"
if [ "$SYSTEM_INSTALL" = "livemedia" ] ; then
  if [ -z "$( findmnt -n -M / | grep "filesystem.squashfs" )" ] && [ -z "$( findmnt -n -M /live/linux | grep " squashfs " )" ] ; then
    echo "Warning: no live system detected"
    SYSTEM_INSTALL="unknown"
    rm -f /etc/q4oslivemedia
    /opt/trinity/bin/kwriteconfig --file "/etc/q4os/q4base.conf" --group "OnInstall" --key "install_type" "unknown"
  fi
fi
echo "System install: $SYSTEM_INSTALL"

CMDLINE1="$( cat /proc/cmdline )"
FUSERNAME="$( dash /usr/share/apps/q4os_system/bin/get_first_user.sh --name )"
if [ -z "$FUSERNAME" ] ; then
  WUBI_DIR_A="$( echo "$CMDLINE1" | grep "/disks/root.disk" | awk -F' loop=' '{ print $2 }' | awk -F' ' '{ print $1 }' | awk -F'/disks/root.disk' '{ print $1 }' | awk -F'^/' '{ print $2 }' )"
  PRESEED_FL1="/mnt/host/$WUBI_DIR_A/install/preseed.cfg"
  if [ -f "$PRESEED_FL1" ] ; then
    FUSERNAME="$( cat "$PRESEED_FL1" | grep "^d-i passwd/username string " | awk -F' ' '{ print $4 }' | tr -d '\r' )"
    FPASSWORD="$( cat "$PRESEED_FL1" | grep "^d-i passwd/user-password-crypted password " | awk -F' ' '{ print $4 }' | tr -d '\r' )"
    FFULLNAME="$( cat "$PRESEED_FL1" | grep "^d-i passwd/user-fullname " | awk -F' ' '{ print $4 " " $5 }' | tr -d '\r' )"
  else
    echo "No preseed.cfg file."
  fi
  if [ -z "$FUSERNAME" ] ; then
    FUSERNAME="adminq"
    FPASSWORD=""
    FFULLNAME="Administrator"
  fi
  echo "Adding new user: $FUSERNAME , $FFULLNAME"
  useradd -m --uid "1000" --shell "/bin/bash" --password "$FPASSWORD" --comment "$FFULLNAME" "$FUSERNAME"
  adduser $FUSERNAME cdrom
  adduser $FUSERNAME floppy
  adduser $FUSERNAME sudo
  adduser $FUSERNAME adm
  adduser $FUSERNAME systemd-journal
  adduser $FUSERNAME audio
  adduser $FUSERNAME dip
  adduser $FUSERNAME video
  adduser $FUSERNAME plugdev
  adduser $FUSERNAME netdev
  adduser $FUSERNAME bluetooth
  adduser $FUSERNAME lpadmin
  adduser $FUSERNAME users
  # chown -R $FUSERNAME:$FUSERNAME /home/$FUSERNAME
  if [ -z "$FPASSWORD" ] ; then
    passwd -d $FUSERNAME
    if [ -f "/usr/bin/startplasma-x11" ] ; then
      echo "Enabling autologin into Plasma ..."
      ctrl-autologin --enable "$FUSERNAME" "" "plasma.desktop"
    elif [ -f "/opt/trinity/bin/starttde" ] ; then
      echo "Enabling autologin into Trinity ..."
      ctrl-autologin --enable "$FUSERNAME" "" "trinity.desktop"
    fi
  fi
fi
echo "First user: $FUSERNAME"

MEMTOTAL=$( q4hw-info --memtotal )
echo "Total memory: $MEMTOTAL"
/opt/trinity/bin/kwriteconfig --file "/etc/q4os/q4base.conf" --group "OnInstall" --key "memory" "$MEMTOTAL"

if [ ! -f "/etc/apt/sources.list" ] ; then
  touch /etc/apt/sources.list #missing after noble install, so create
fi

if [ -f "/var/log/installer/syslog" ] ; then
  chmod a+r /var/log/installer/syslog #add read permissions for ordinary users; may not be at install phase, as syslog file is not present yet
fi
mv /var/lib/q4os/.devcpq4.sh /tmp/
fc-cache & #create fonts cache as early as possible

echo "Detecting Virtualbox guest ..."
VBOXENV="$( q4hw-info --vboxguest )"
if [ "$VBOXENV" = "VBoxGuest_Yes" ] ; then
  echo "Q4OS Info: Running inside Virtualbox"
  # touch /tmp/.frst_q4_boot_vbox.stp
  /opt/trinity/bin/kwriteconfig --file "/etc/q4os/q4base.conf" --group "OnInstall" --key "in_virtualbox" "1"
  echo "  Blacklisting piix4_smbus kernel module ..."
  echo "blacklist i2c_piix4" > /etc/modprobe.d/blacklist-vbox_piix4_smbus.conf #fix piix4_smbus error message on startup
else
  echo "Q4OS Info: Virtualbox not detected"
fi

echo "Detecting Synaptics touchpad ..."
if q4hw-info --synaptics ; then
  echo "Synaptics touchpad detected .."
  # mv /etc/X11/xorg.conf.d/.50-synaptics.conf.disabled /etc/X11/xorg.conf.d/50-synaptics.conf
  # touch /tmp/.swprfl-acndrq-30.tmp
  # synclient TapButton1=1 TapButton2=2 VertEdgeScroll=1
fi

echo "Detecting Thinkpad notebook ..."
if q4hw-info --thinkpad-r51 ; then
  echo " .. we are on thinkpad-r51, disable i915 kms .."
  touch /etc/modprobe.d/i915.conf
  echo 'options i915 modeset=0' > /etc/modprobe.d/i915.conf
  touch /tmp/.swprfl-acndrq-30.tmp #restart needed for i915 options to be activated
fi

if [ "$SYSTEM_INSTALL" != "livemedia" ] ; then
  #fixing a few debian bugs, preconfigure debconf for dpkg to work in noninteractive mode
  if [ "$( dash /usr/share/apps/q4os_system/bin/print_package_version.sh "grub-pc" )" != "0" ] ; then
    if [ -z "$( debconf-show grub-pc | grep "grub-pc/install_devices:" | awk -F': ' '{ print $2 }' | tr -d '\n' | tr -d ' ' )" ] ; then
      #fix https://sourceforge.net/p/q4os/tickets/148/
      echo "Preconfiguring grub-pc for debconf to work noninteractively ..."
      echo "set grub-pc/install_devices_empty true" | debconf-communicate -f noninteractive
    fi
  fi
  if [ "$( dash /usr/share/apps/q4os_system/bin/print_package_version.sh "shim-signed-common" )" != "0" ] ; then
    echo "Preconfiguring shim-signed-common for debconf to work noninteractively ..."
    echo "set shim/disable_secureboot false" | debconf-communicate -f noninteractive
    echo "set shim/enable_secureboot true" | debconf-communicate -f noninteractive
  fi
fi

if [ -z "$FUSERNAME" ] ; then
  echo "[Error:] No first user, there must be one !"
else
  #first user specific configuration
  if [ -f "/usr/share/apps/q4os_system/share/q4os_fuserhome.tar.gz" ] ; then
    echo "Copying files for first user: $FUSERNAME"
    tar -C /home/$FUSERNAME/ -xhzf /usr/share/apps/q4os_system/share/q4os_fuserhome.tar.gz
  fi
  if dash /usr/share/apps/q4os_system/bin/print_package_version.sh "lookswitcher-trinity" > /dev/null ; then
    echo "Removing lookswitcher shortcut from the control panel ..."
    rm -f /home/$FUSERNAME/.local/share/applications/kcm_lookswitcher_wrapper.desktop
  fi
  if [ -f "/home/$FUSERNAME/.local/share/q4os/lookswitcher/kcm_lookswitcher_wrapper.desktop" ] ; then
    #set the full path to show correct icon in tde
    sed -i "s:^Icon=~:Icon=/home/$FUSERNAME:" /home/$FUSERNAME/.local/share/q4os/lookswitcher/kcm_lookswitcher_wrapper.desktop
  fi
  if [ -f "/home/$FUSERNAME/.local/share/q4os/nvdinstl/nvdinstl_inst.desktop" ] ; then
    sed -i "s:^Icon=~:Icon=/home/$FUSERNAME:" /home/$FUSERNAME/.local/share/q4os/nvdinstl/nvdinstl_inst.desktop
  fi
  if [ -f "/home/$FUSERNAME/.local/share/q4os/vboxgutils/vboxgutils_inst.desktop" ] ; then
    sed -i "s:^Icon=~:Icon=/home/$FUSERNAME:" /home/$FUSERNAME/.local/share/q4os/vboxgutils/vboxgutils_inst.desktop
  fi
  chown -R $FUSERNAME:$FUSERNAME /home/$FUSERNAME
fi

A_QAPTDISTR="$( dash /usr/share/apps/q4os_system/bin/print_qaptdistr.sh )"
echo "Distro: $A_QAPTDISTR"

echo "Running hooks ..."
for SCRPT1 in /usr/share/apps/q4os_system/bhooks/bhook1_*.sh ; do
  if [ -f "$SCRPT1" ] ; then
    echo "Sourcing sript ... $SCRPT1"
    . $SCRPT1
  fi
done
echo "Finished hooks ..."

echo "decide whether to enable unattended-upgrades ..."
if [ "$SYSTEM_INSTALL" = "livemedia" ] ; then
  echo "do not enable unattended-upgrades for live media"
else
  if [ -f "/usr/bin/startplasma-x11" ] ; then
    echo "periodic updates enabled, while unattended-upgrades disabled for plasma"
    dash /usr/share/apps/q4os_system/bin/aptwriteconfig.sh "/etc/apt/apt.conf.d/20auto-upgrades" "APT::Periodic::Update-Package-Lists" "1"
    dash /usr/share/apps/q4os_system/bin/aptwriteconfig.sh "/etc/apt/apt.conf.d/20auto-upgrades" "APT::Periodic::Unattended-Upgrade" "0"
  else
    if [ "$MEMTOTAL" -lt "2000" ] ; then
      echo "do not enable unattended-upgrades for low memory machines"
    elif [ "$A_QAPTDISTR" = "raspbian10" ] || [ "$A_QAPTDISTR" = "raspbian12" ] ; then
      echo "do not enable unattended-upgrades for raspberrypi"
    else
      echo "periodic updates enabled, while unattended-upgrades disabled"
      dash /usr/share/apps/q4os_system/bin/aptwriteconfig.sh "/etc/apt/apt.conf.d/20auto-upgrades" "APT::Periodic::Update-Package-Lists" "1"
      dash /usr/share/apps/q4os_system/bin/aptwriteconfig.sh "/etc/apt/apt.conf.d/20auto-upgrades" "APT::Periodic::Unattended-Upgrade" "0"
    fi
  fi
fi

#for testing purposes, to force running wifi connection tool on the first boot
#may be removed as not needed
if [ -n "$( echo "$CMDLINE1" | grep "forcetdewifiman" )" ] ; then
  echo "force running wifi connection tool on the first boot."
  touch "/tmp/.forcetdewifiman.stp"
fi

#dirty hack to disable show khelpcenter release notes at the first login
#remove later as fixed in tde sources
rm -f /opt/trinity/share/autostart/tde_release_notes.desktop

if [ -f "/var/lib/q4os/run_update_initramfs_on_first_boot.stp" ] ; then
  echo "running update-initramfs -u as requested ..."
  update-initramfs -u
  # rm /var/lib/q4os/run_update_initramfs_on_first_boot.stp
fi

if [ -f "/var/lib/q4os/run_update_grub_on_first_boot.stp" ] ; then
  echo "running update-grub as requested ..."
  update-grub
  # rm /var/lib/q4os/run_update_grub_on_first_boot.stp
fi

if [ -f "/tmp/.swprfl-acndrq-30.tmp" ] ; then
  chmod a+rw /tmp/.swprfl-acndrq-30.tmp #to enable removal by a user first boot process
fi
chmod a+r /etc/q4os/q4base.conf
rm -rf /.trinity #fix: kwriteconfig creates this directory in rootfs; probably TDEHOME=/root must be set for kwriteconfig to fix the glitch

touch "/var/lib/q4os/first_boot_script_done.stp"
systemctl disable q4os_first_boot.service
echo "\n>> Q4OS first boot script finished: $( date +%Y-%m-%d-%H-%M-%S ) <<"
journalctl --no-pager -u q4os_first_boot.service -all > /var/log/fstbootsrv.log
