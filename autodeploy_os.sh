#!/bin/bash

# Requements:
# 	Debian family
# 	LXDE, XFCE(???) desktop managers

printf "Set Desktop count... "
echo "Run obconf and go to Desktop"
obconf
echo -n "done.\n"

printf "Set screen brightness... "
# https://linuxcritic.wordpress.com/2015/03/29/change-screen-brightness-in-lxde/
# xrandr -q | grep connected
xrandr --output LVDS --brightness 0.9
echo -n "done.\n"

printf "Installing packages... "
sudo apt-get update
echo "for console"
sudo apt-get install -y vim openssh-server openssh-client git tree
echo "git settings"
git config --global user.email "snaiffer@gmail.com"
git config --global user.name "snaiffer"
echo "ssh settings"
# edit /etc/ssh/ssh_config: comment all lines with GSS
# setting for keeping connection ~/.ssh...
echo "for WWW"
sudo apt-get install -y transmission chromium-browser
echo "Pepper Flash Player"
sudo add-apt-repository -y ppa:skunk/pepper-flash
sudo apt-get update && sudo apt-get install -y pepflashplugin-installer
sudo sh -c 'echo ". /usr/lib/pepflashplugin-installer/pepflashplayer.sh" >> /etc/chromium-browser/default'
# to check if it has been success:
## open chromium and input "chrome://plugins" in the address line

echo "systems"
sudo apt-get install -y terminator mtp-tools mtpfs pavucontrol
echo "others"
sudo apt-get install -y basket meld libreoffice gimp pinta
# https://github.com/cas--/PasteImg
sudo mv data/pasteimg /usr/bin/
echo -n "done.\n"

printf "Set keyboardlayout switcher by Caps key... "
sudo cp data/keyboardlayout_switcher.desktop /etc/xdg/autostart/
echo -n "done.\n"

printf "Set sync-scripts... "
sudo mkdir -p /usr/bin/added/ && \
sudo cp -f data/sync_fromExHardToSnaifLaptop.sh /usr/bin/added/ && \
sudo cp -f data/sync_fromSnaifLaptopToExHard.sh /usr/bin/added/
echo -n "done.\n"

printf "Setting bash enviroment... "
git clone https://github.com/snaiffer/bash_env.git ~/.bash_env
~/.bash_env/install.sh
echo -n "done.\n"

printf "Setting vim... "
sudo apt-get -y install -y vim git ctags clang libclang-dev
rm -Rf ~/.vim ~/.vimrc
git clone https://github.com/snaiffer/vim.git ~/.vim
ln -s ~/.vim/vimrc ~/.vimrc
vim -c "BundleInstall" -c 'qa!'
echo -n "done.\n"



