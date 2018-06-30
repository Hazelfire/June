
encrypt_device(){
echo "What password should we use to lock your system?"
read -s password

echo "Can you confirm that password?"
read -s confirm_password

if [[ "$password" == "$confirm_password" ]]; then
  echo "Password confirmed"
  echo "YES\n$password\n$password" | cryptsetup -v luksFormat $root_partition
  echo "$password" | cryptsetup open $root_partition cryptroot

else
	echo "Passwords did not match"
	exit
fi

}


# Ask where to install to
lsblk
echo "What disk should we install to?"
read install_device
install_device="/dev/"$install_device

# Are we on a UEFI system?
if [ -d '/sys/firmware/efi' ]; then
  cat uefi_fdisk.input | fdisk $install_device
  uefi_partition="$install_device""1"
  root_partition="$install_device""2"
  encrypt_device
  mkfs.vfat -F32 $uefi_partition
  mkfs.ext4 /dev/mapper/cryptroot
  mount /dev/mapper/cryptroot /mnt
  mkdir /mnt/boot
  mount $uefi_partition /mnt/boot
else
  cat bios_fdisk.input | fdisk $install_device
  root_partition="$install_device" "1"
  encrypt_device
  mkfs.ext4 /dev/mapper/cryptroot
  mount /dev/mapper/cryptroot /mnt
fi

# Check our internet connection
ping -n 1 www.archlinux.com

if [ $? -eq 0 ]; then
  wifi-menu
fi

sudo pacman -Sy
yes | sudo pacman -S pacman-contrib
cp /etc/pacman.d/mirrorlist mirrors

echo "Ranking your mirrors, this makes package downloading faster."
./rankmirrors mirrors > /etc/pacman.d/mirrorlist

timedatectl set-ntp true

# Now for the fun part, installing the system
echo "Downloading and installing the system, this is the big step, go get a coffee or something"
yes | pacstrap /mnt base base-devel vim cryptsetup i3 zsh

genfstab -U /mnt >> /mnt/etc/fstab

echo "Copying config files over"
cp mkinitcpio.conf /mnt/etc/mkinitcpio.conf
cp locale-gen /mnt/locale-gen
cp -r loader /mnt/boot
echo "options		cryptdevice=$(blkid $root_partition | cut -d" " -f2 | sed "s/\"//g"):cryptroot root=/dev/mapper/cryptroot quiet loglevel=3 rd.udev.log-priority=3 splash rw" >> /mnt/boot/loader/entries/arch.conf

echo "Entering new system for configuration"
cp system_config.sh /mnt
cat "bash system_config.sh "$password | arch-chroot /mnt

echo "Done! poweroff and reboot the system without the usb"
