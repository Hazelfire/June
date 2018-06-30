echo "What's your Region?"
ls /usr/share/zoneinfo
read country

echo "What's your City?"
ls '/usr/share/zoneinfo/'$country
read city

ln -sf '/usr/share/zoneinfo/'$country'/'$city /etc/localtime
hwclock --systohc

echo "Ok, this needs some user help, I couldn't think up of a better way to do this (enter to continue)"
read
echo "I'm going to open nano so that you can uncomment your locale. (enter to continue)"
read
echo "All you need to do is find the line that is your locale, for instance, Australian english is en_AU.UTF8 (enter to continue)"
read
echo "There will be 2 options for your language, choose the UTF8 one (enter to continue)"
read
echo "Are you ready? (enter to continue)"
read

nano /etc/locale.gen

echo "Ok, we're done with locale."
echo "LANG=$(sudo bash locale-gen)" > /etc/locale.conf

echo "Now for the fun part, choose a hostname!"
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1 $hostname.localdomain $hostname" >> /etc/hosts

echo "Building the boot image"
mkinitcpio -p linux

echo "root:"$1 | chpasswd

echo "Installing bootloader"
bootctl --path=/boot install

if [ -z "$(lscpu | grep Intel)" ]; then
	echo "Detected intel CPU, installing intel ucode"
	yes | pacman -S intel-ucode
	echo "initrd		/intel-ucode.img"
fi

packages=("i3" "zsh" "xorg-server" "lightdm" "mesa" "rxvt-unicode" "feh" "udisks2" "networkmanager" "blueman" "bluez" "bluez-utils" "dmenu" "zsh")

if lspci | grep VGA | grep Intel ; then
	echo "Intel graphics detected"
	packages+=("xf86-video-intel")
fi

if lspci | grep VGA | grep AMD ; then
	echo "AMD graphics detected"
	packages+=("xf86-video-amdgpu")
fi

if lspci | grep VGA | grep  VirtualBox ; then
	echo "Virtualbox detected"
	packages+=("virtualbox-guest-modules-arch" "virtualbox-guest-utils")
fi

echo "Installing system packages"
yes "" | sudo pacman -S ${packages[@]} --noconfirm

systemctl enable lightdm.service
systemctl enable NetworkManager.service
systemctl enable bluetooth.service

echo "What do you want your main user to be called?"
read username

echo $username":"$1

groupadd autologin
useradd -m -G wheel,autologin -s /usr/bin/zsh $username

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

cat lightdm.conf | sed 's/REPLACE_WITH_USERNAME/'$username'/g' > /etc/lightdm/lightdm.conf
cp xinitrchelper /bin
cp xinitrc.desktop /usr/share/xsessions

echo "Creating user environment"
cp .Xresources '/home/'$username
cp .xinitrc '/home/'$username
mkdir '/home/'$username'/.i3'
cp i3config '/home/'$username'/.i3/config'

mkdir '/home/'$username'/Pictures'
cp wallpaper.jpg '/home/'$username'/Pictures'

mkdir -p '/home/'$username'/.local/share/fonts'
cp fonts/* '/home/'$username'/.local/share/fonts'

su sam -c "sh -c \"$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)\""
cp .zshrc '/home/'$username

