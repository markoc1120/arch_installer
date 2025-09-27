#!/bin/bash

mkdir -p "/home/$(whoami)/Documents"
mkdir -p "/home/$(whoami)/Downloads"
mkdir -p "/home/$(whoami)/src"

aur_install() {
    curl -O "https://aur.archlinux.org/cgit/aur.git/snapshot/$1.tar.gz" \
    && tar -xvf "$1.tar.gz" \
    && cd "$1" \
    && makepkg --noconfirm -si \
    && cd - \
    && rm -rf "$1" "$1.tar.gz" ;
}

install_paru() {
    cd /tmp
    sudo pacman -S --needed --noconfirm base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd /tmp
    rm -rf paru
}

install_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh 
}

aur_check() {
    qm=$(pacman -Qm | awk '{print $1}')
    for arg in "$@"
    do
        if [ "$arg" = "rust" ]; then
            install_rust
        elif [[ "$qm" != *"$arg"* ]]; then
            paru --noconfirm -S "$arg" &>> /tmp/aur_install \
            || aur_install "$arg" &>> /tmp/aur_install
        fi
    done
}

dialog --infobox "Installing \"Paru\", an AUR helper..." 10 60
install_paru
count=$(wc -l < /tmp/aur_queue)
c=0

cat /tmp/aur_queue | while read -r line
do
    c=$(( "$c" + 1 ))
    dialog --infobox \
    "AUR install - Downloading and installing program $c out of $count:
        $line..." \
    10 60
    aur_check "$line"
done

DOTFILES="/home/$(whoami)/src/dotfiles"
if [ ! -d "$DOTFILES" ]; then
    git clone https://github.com/markoc1120/dotfiles.git \
    "$DOTFILES" >/dev/null
fi

source "$DOTFILES/zsh/.zshenv"
cd "$DOTFILES" && bash install.sh
