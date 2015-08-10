#!/bin/bash

# Requements:
# 	Debian family
# 	LXDE, XFCE(???) desktop managers

dir_script=`dirname $0`
dir_data="$dir_script/data"

printf "Install & Set git... "
sudo apt-get install -q -y git > /dev/null
echo "git settings"
git config --global user.email "snaiffer@gmail.com"
git config --global user.name "snaiffer"
git config --global push.default matching   # push all branches
# git config --global push.default simple   # push the current branch only
echo -n "done."

echo "Intalling libraries for bash..."
sudo git clone https://github.com/snaiffer/lib_bash_general.git /usr/lib/lib_bash_general && \
source /usr/lib/lib_bash_general/lib_bash_general.sh
check_status

#printf "Set Desktop count... "
#echo "Run obconf and go to Desktop"
#obconf
#check_status

#echo "Set screen brightness... "
## https://linuxcritic.wordpress.com/2015/03/29/change-screen-brightness-in-lxde/
## xrandr -q | grep connected
#xrandr --output LVDS --brightness 0.9
#check_status

echo "Removing packages... "
sudo apt-get remove -q -y abiword* gnumeric* xfburn parole > /dev/null
check_status

echo "Installing packages... "
sudo apt-get update > /dev/null
echo "for console"
sudo apt-get install -q -y vim openssh-server openssh-client tree nmap iotop > /dev/null
echo "ssh settings"
echo "turn off GSS for fast connection..."
sudo echo "GSSAPIAuthentication no" >> /etc/ssh/ssh_config
echo "setting for keeping connection ~/.ssh..."
cat <<-EOF > ~/.ssh/config
Host *
ControlMaster auto
ControlPath ~/.ssh/cm_%r@%h:%p
EOF
echo "for WWW"
sudo apt-get install -q -y transmission chromium-browser > /dev/null
echo "Pepper Flash Player"
sudo add-apt-repository -y ppa:skunk/pepper-flash
sudo apt-get update > /dev/null && sudo apt-get install -q -y pepflashplugin-installer > /dev/null
sudo sh -c 'echo ". /usr/lib/pepflashplugin-installer/pepflashplayer.sh" >> /etc/chromium-browser/default'
# to check if it has been success:
## open chromium and input "chrome://plugins" in the address line

echo "systems"
sudo apt-get install -q -y terminator mtp-tools mtpfs pavucontrol > /dev/null
echo "others"
sudo apt-get install -q -y basket meld libreoffice gimp pinta > /dev/null
# https://github.com/cas--/PasteImg
sudo mv data/pasteimg /usr/bin/
check_status

#echo "Set keyboardlayout switcher by Caps key... "
#sudo cp data/keyboardlayout_switcher.desktop /etc/xdg/autostart/
#check_status

#echo "Set sync-scripts... "
#sudo mkdir -p /usr/bin/added/ && \
# sudo cp -f data/sync_fromExHardToSnaifLaptop.sh /usr/bin/added/ && \
# sudo cp -f data/sync_fromSnaifLaptopToExHard.sh /usr/bin/added/
#check_status

echo "Setting bash enviroment... "
git clone https://github.com/snaiffer/bash_env.git ~/.bash_env && \
 ~/.bash_env/install.sh
check_status

echo "Setting vim... "
sudo apt-get install -q -y vim git ctags clang libclang-dev > /dev/null
rm -Rf ~/.vim ~/.vimrc
git clone https://github.com/snaiffer/vim.git ~/.vim
ln -s ~/.vim/vimrc ~/.vimrc
vim -c "BundleInstall" -c 'qa!'
check_status

echo "Setting the windows manager enviroment... "
# Close/minimize/maximize button not appearing
 DISPLAY=:0.0 gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close,' && \
 DISPLAY=:0.0 gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Droid Sans Bold 10' && \
# list of themes: /usr/share/themes/
 DISPLAY=:0.0 gsettings set org.gnome.desktop.wm.preferences theme 'Greybird'
check_status

echo "Switch xfwm4 to compiz. Autostart compiz... "
#http://www.webupd8.org/2012/11/how-to-set-up-compiz-in-xubuntu-1210-or.html
cp /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml && \
 sed -i "s/xfwm4/compiz/" ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
check_status

echo "Installing plugins for Desktop Enviroment... "
sudo apt-get install -q -y xfce4-clipman-plugin xfce4-datetime-plugin xfce4-time-out-plugin > /dev/null
check_status

echo "Installing dockbar (side-panel) ... "
# http://www.webupd8.org/2013/03/dockbarx-available-as-xfce-panel-plugin.html
# if you want preview: install compiz and add KDE compability
sudo add-apt-repository -y ppa:dockbar-main/ppa && \
 sudo apt-get update > /dev/null && \
 sudo apt-get install -q -y --no-install-recommends xfce4-dockbarx-plugin > /dev/null
check_status

echo "Adding to autostart dockbar ... "
sudo sh -c 'cat <<-EOF > /etc/xdg/autostart/dockx.desktop
[Desktop Entry]
Encoding=UTF-8
Name=dockx
Comment=dockx
Exec=dockx
Type=Application
EOF'
check_status

echo "Installing system load indicator for Desktop Enviroment... "
sudo add-apt-repository -y ppa:indicator-multiload/stable-daily && \
 sudo apt-get update > /dev/null && \
 sudo apt-get install -q -y indicator-multiload > /dev/null && \
echo 'Run "System load indicator" from x11 (graphic mode)'
check_status

echo "Export settings... "
cp -Rf $dir_data/config/xfce4 ~/.config/
cp -Rf $dir_data/gconf ~/.gconf
check_status

