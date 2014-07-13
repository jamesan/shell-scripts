#!/bin/bash

# ASSUME: pkg/repo cache is located at /mnt2/Platforms/Linux/Arch/pacman/`uname -m`/{pkg,sync,pkgfile}
# ASSUME: access to the Internet is already configured or the pkg/repo cache is sufficient

LOGFILE=${LOGFILE:-~/log}

{ # Try block

echo 'Wiping and partitioning disk...'
sgdisk -Z /dev/sda >> $LOGFILE                                                             &&
sgdisk -o /dev/sda >> $LOGFILE                                                             &&
SWAPSIZE=$((`free -tk | sed -n 2p | tr -s ' ' | cut -f2 -d' '`*2))                         &&
START=`sgdisk -D /dev/sda`                                                                 &&
ROOT=$((START+100*2048))                                                                   &&
END=$((`sgdisk -E /dev/sda`/2048*2048-1))                                                  &&
SWAP=$(((END-SWAPSIZE)/2048*2048))                                                         &&
sgdisk -n 1:$START:$((ROOT-1)) -n 2:$ROOT:$((SWAP-1)) -n 3:$SWAP:$END /dev/sda >> $LOGFILE &&
sgdisk -t 1:ef02 -t 2:8300 -t 3:8200 -A 1:set:2 /dev/sda >> $LOGFILE

} || { # Catch block

echo 'An error occurred. Halting... please review stderr, reset the block device and re-run this script.' 2>&1
exit 1

}

{ # Try block

echo 'Creating filesystems...'
mkfs.fat -F 32 -n BOOT /dev/sda1 >> $LOGFILE &&
mkfs.ext4 -q -L Root /dev/sda2 >> $LOGFILE   &&
mkswap -L Swap /dev/sda3 &>> $LOGFILE        &&
mount /dev/sda2 /mnt                         &&
mkdir /mnt/boot                              &&
mount /dev/sda1 /mnt/boot                    &&
swapon /dev/sda3

} || { # Catch block

echo 'An error occurred. Halting... please review stderr, reset the block device and re-run this script.' 2>&1
exit 1

}

{ # Try block

# Connect cached package/repo files
mkdir -p /mnt/var/{cache/{pacman/pkg,pkgfile},lib/pacman/sync}                                                                &&
mountpoint -q /mnt/var/cache/pacman/pkg || mount --bind /mnt2/pacman/x86_64/pkg /mnt/var/cache/pacman/pkg  &&
mountpoint -q /mnt/var/lib/pacman/sync  || mount --bind /mnt2/pacman/x86_64/sync /mnt/var/lib/pacman/sync  &&
mountpoint -q /mnt/var/cache/pkgfile    || mount --bind /mnt2/pacman/x86_64/pkgfile /mnt/var/cache/pkgfile

} || { # Catch block

echo 'An error occurred. Halting... please review stderr, reset the block device and re-run this script.' 2>&1
exit 1

}

{ # Try block

echo 'Installing Arch Linux basic packages...'
sed -i 's/\-Sy/-S/' `which pacstrap`             &&
pacstrap /mnt acpid base bash-completion crda dkms dosfstools gpm gptfdisk hdparm htop hwdetect lm_sensors mlocate moreutils mosh mtools ncdu networkmanager networkmanager-dispatcher-openntdp openntpd openssh p7zip partclone pkgfile reflector sdparm sudo syslinux upx xclip xdelta3 &>> $LOGFILE &&
pacstrap /mnt base-devel ccache bzr cvs git svn >> $LOGFILE        &&
sed -i 's/\-S/-Sy/' `which pacstrap`             &&
genfstab -pU /mnt > /mnt/etc/fstab               &&
syslinux-install_update -c /mnt -iam >> $LOGFILE &&
ROOT=`lsblk /dev/sda2 -rno PARTUUID`             &&
SWAP=`lsblk /dev/sda3 -rno PARTUUID`             &&
sed -i "s/^UI/#UI/;s/\/dev\/sda3/PARTUUID=$ROOT resume=PARTUUID=$SWAP quiet/" /mnt/boot/syslinux/syslinux.cfg
arch-chroot /mnt /usr/bin/pkgfile -u

} || { # Catch block

echo 'An error occurred. Halting... please review stderr, reset the block device and re-run this script.' 2>&1
exit 1

}

{ # Try block

echo 'Configuring minimum system settings...'
echo 'new.pc.jamesan.ca' > /mnt/etc/hostname                                                     &&
[ -L /mnt/etc/localtime ] || ln -s /usr/share/zoneinfo/America/Toronto /mnt/etc/localtime &&
sed -i 's/^#en_CA/en_CA/' /mnt/etc/locale.gen                                             &&
arch-chroot /mnt /usr/bin/locale-gen >> $LOGFILE                                          &&
locale | sed 's/en_US/en_CA/;s/UTF-8/UTF-8/;s/^LC_COLLATE.*$/LC_COLLATE="C"/;' | cat <(echo 'LANGUAGE="en_CA:en_GB:en"') - > /mnt/etc/locale.conf &&
echo -e 'KEYMAP=us\nFONT=Lat2-Terminus16\nFONTMAP=8859-1' > /mnt/etc/vconsole.conf        &&
sed -i 's/^HOOKS.*$/HOOKS="base udev autodetect block resume filesystems fsck"/' /mnt/etc/mkinitcpio.conf       &&
arch-chroot /mnt /usr/bin/mkinitcpio -p linux &>> $LOGFILE                                &&
sed -i "s/^#Color/Color/;s/^#TotalDownload/;s/^#VerbosePkgLists/;s/^LocalFileSigLevel/#LocalFileSigLevel/" /mnt/etc/pacman.conf &&
# Uncomment repos in pacman.conf: testing community-testing
arch-chroot /mnt /usr/bin/pacman -Syu --noconfirm
arch-chroot /mnt /usr/bin/updatedb

} || { # Catch block

echo 'An error occurred. Halting... please review stderr, reset the block device and re-run this script.' 2>&1
exit 1

}

{ # Try block

echo 'Configuring user accounts...'
arch-chroot /mnt /usr/bin/getent passwd jan > /dev/null || \
    arch-chroot /mnt /usr/bin/useradd -mNG wheel,users jan         &&
arch-chroot /mnt /usr/bin/passwd -q -d jan                         &&
arch-chroot /mnt /usr/bin/passwd -q -d root                        &&
arch-chroot /mnt /usr/bin/passwd -q -e root                        &&
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /mnt/etc/sudoers.d/wheel   &&
chmod 0440 /mnt/etc/sudoers.d/wheel
systemctl enable NetworkManager acpid acpid.socket openntpd sshd

} || { # Catch block

echo 'An error occurred. Halting... please review stderr, reset the block device and re-run this script.' 2>&1
exit 1

}

{ # Try block

echo 'Configuring AUR package building...'
arch-chroot /mnt /usr/bin/pacman-key -r 001BED01 >> $LOGFILE                 &&
arch-chroot /mnt /usr/bin/pacman-key --lsign-key 001BED01 >> $LOGFILE        &&
sed -i '/^BUILDENV/ s/\!sign/sign/;s/\!ccache/ccache/' /mnt/etc/makepkg.conf &&
sed '/^OPTIONS/ s/docs/\!docs/;s/\!upx/upx/' /mnt/etc/makepkg.conf           &&

sed -i 's/^#PKGDEST.*$/PKGDEST=\/var\/abs\/local\/pkgs/' /mnt/etc/makepkg.conf          &&
sed -i 's/^#SRCDEST.*$/SRCDEST=\/var\/abs\/local\/srcs/' /mnt/etc/makepkg.conf          &&
sed -i 's/^#SRCPKGDEST.*$/SRCPKGDEST=\/var\/abs\/local\/srcpkgs/' /mnt/etc/makepkg.conf &&
sed -i 's/^#LOGDEST.*$/LOGDEST=\/var\/abs\/local\/logs/' /mnt/etc/makepkg.conf          &&
sed -i 's/^#PACKAGER.*$/PACKAGER="James An <james@jamesan.ca>"/' /mnt/etc/makepkg.conf  &&
sed -i 's/^#GPGKEY.*$/GPGKEY="001BED01"/' /mnt/etc/makepkg.conf

} || { # Catch block

echo 'An error occurred. Halting... please review stderr, reset the block device and re-run this script.' 2>&1
exit 1

}

echo 'Success!'
echo 'A password-less guest account has been added and the' $'\n' \
     'root account will required a new password on its next login.'

echo 'Unmounting devices to prepare for reboot...'
mount | grep /mnt/var | cut -f3 -d' ' | \
while read mnt ; do
    umount $mnt
done
mountpoint -q /mnt/boot         && umount /mnt/boot
mountpoint -q /mnt              && umount /mnt
swapon | grep sda3 &> /dev/null && swapoff /dev/sda3

echo 'Ready to reboot into the new Arch installation!'
