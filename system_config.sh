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

echo "Enter your root password"
passwd

echo "Installing bootloader"
bootctl --path=/boot install
