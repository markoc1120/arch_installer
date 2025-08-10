#!/bin/bash

Never tun pacman -Sy on your system
pacman -Sy dialog
timedatectl set-ntp true
cp config_template.json /tmp/config.json

dialog --defaultno --title "Are you sure?" --yesno \
"This is my personnal arch linux install. \n\n\
Do you want to install arch based on predefined config or not?"\
15 60 || archinstall

# stdout is used by dialog to output the dialog boxes so we save user inputs to stderr
dialog --no-cancel --inputbox "Enter a name for your computer." \
10 60 2> comp
comp=$(cat comp) && rm comp

sed -i "s/%comp/$comp/g" /tmp/config.json

devices_list=($(lsblk -d | awk '{print "/dev/" $1 " " $4 " on"}' \
    | grep -E 'sd|hd|vd|nvme|mmcblk'))

dialog --title "Choose your hard drive" --no-cancel --radiolist \
"Where do you want to install your new system? \n\n\
Select with SPACE, valid with ENTER. \n\n\
WARNING: Everything will be DESTROYED on the hard disk!" \
15 60 4 "${devices_list[@]}" 2> hd
hd=$(cat hd) && rm hd
hd=$(echo "$hd" | sed 's#/#\\/#g')
sed -i "s/%hd/$hd/g" /tmp/config.json

dialog --title "Continue installation" --yesno \
"Do you want to install all your apps and your dotfiles?" \
10 60 \
&& curl https://raw.githubusercontent.com/markoc1120\
/arch_installer/main/install_apps.sh > /tmp/install_apps.sh \
&& bash /tmp/install_apps.shrm /mnt/var_uefi

dialog --title "To reboot or not to reboot?" --yesno \
"Congrats! The install is done! \n\n\
Do you want to reboot your computer?" 20 60

response=$?
case $response in
    0) reboot;;
    1) clear;;
esac
