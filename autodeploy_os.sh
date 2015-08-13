#!/bin/bash

# Requements:
# 	Debian family
# 	LXDE, XFCE(???) desktop managers

export dir_script=`dirname $0`
export dir_data="$dir_script/data"
export bin="/usr/bin"
export virtualbox_version='5.0'

# auth. for sudo
sudo echo

printf "Install & Set git... "
sudo apt-get install -q -y git > /dev/null && \
git config --global user.email "snaiffer@gmail.com" && \
git config --global user.name "Alexander Danilov" && \
git config --global push.default matching   # push all branches
# git config --global push.default simple   # push the current branch only
echo "done."

printf "Intalling libraries for bash... "
sudo git clone -q https://github.com/snaiffer/lib_bash_general.git /usr/lib/lib_bash_general && \
source /usr/lib/lib_bash_general/lib_bash_general.sh
check_status

#printf "Set Desktop count... "
#echo "Run obconf and go to Desktop"
#obconf
#check_status

#printf "Set screen brightness... "
## https://linuxcritic.wordpress.com/2015/03/29/change-screen-brightness-in-lxde/
## xrandr -q | grep connected
#xrandr --output LVDS --brightness 0.9
#check_status

echo
printf "Removing packages... "
sudo apt-get remove -q -y abiword* gnumeric* xfburn parole gmusicbrowser xfce4-notes firefox xfce4-terminal > /dev/null
check_status

echo
echo "Installing packages:"
sudo apt-get update > /dev/null
printf "for console... "
sudo apt-get install -q -y vim openssh-server openssh-client tree nmap iotop htop foremost > /dev/null
check_status
echo -e "\t ssh settings:"
printf "\t turn off GSS for fast connection... "
sudo sh -c 'echo "GSSAPIAuthentication no" >> /etc/ssh/ssh_config'
check_status
printf "\t setting for keeping connection ~/.ssh... "
mkdir ~/.ssh && \
cat <<-EOF > ~/.ssh/config
Host *
ControlMaster auto
ControlPath ~/.ssh/cm_%r@%h:%p
EOF
check_status
printf "for WWW... "
sudo apt-get install -q -y transmission chromium-browser > /dev/null
check_status
printf "Pepper Flash Player... "
sudo add-apt-repository -y ppa:skunk/pepper-flash &> /dev/null && \
sudo apt-get update > /dev/null && sudo apt-get install -q -y pepflashplugin-installer > /dev/null && \
sudo sh -c 'echo ". /usr/lib/pepflashplugin-installer/pepflashplayer.sh" >> /etc/chromium-browser/default' > /dev/null
# to check if it has been success:
## open chromium and input "chrome://plugins" in the address line
check_status
echo "systems... "
printf "systems... "
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && \
  sudo apt-get install -q -y terminator mtp-tools mtpfs pavucontrol ubuntu-restricted-extras &> /dev/null
check_status
printf "VirtualBox... "
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add - && \
sudo apt-get update > /dev/null && sudo apt-get install -q -y virtualbox-$virtualbox_version > /dev/null
check_status
printf "others... "
sudo apt-get install -q -y basket meld libreoffice gimp pinta k3b skanlite simple-scan gnome-mplayer vlc wine unetbootin > /dev/null && \
# https://github.com/cas--/PasteImg
sudo cp -f $dir_data/pasteimg $bin && sudo chmod +x $bin/pasteimg
check_status

echo
printf "Set keyboardlayout switcher by Caps key... "
sudo sed -i "s/XKBOPTIONS=\"/XKBOPTIONS=\"grp:caps_toggle\,/" /etc/default/keyboard
## work on HP Pavilion laptop with Lubuntu
#sudo cp -f $dir_data/keyboardlayout_switcher.desktop /etc/xdg/autostart/
check_status

printf "Set sync-scripts... "
sudo mkdir -p $bin && \
 sudo cp -Rf $dir_data/sync $bin/ && \
 sudo chmod +x -R $bin/sync/*
check_status

printf "Setting bash enviroment... "
git clone -q https://github.com/snaiffer/bash_env.git ~/.bash_env && \
 ~/.bash_env/install.sh > /dev/null
check_status

printf "Setting vim... "
sudo apt-get install -q -y vim git ctags clang libclang-dev > /dev/null && \
rm -Rf ~/.vim ~/.vimrc && \
git clone -q https://github.com/snaiffer/vim.git ~/.vim && \
ln -s ~/.vim/vimrc ~/.vimrc && \
vim -c "BundleInstall" -c 'qa!'
check_status

echo
echo "Setting Desktop Enviroment"
printf "Installing compiz (windows manager)... "
sudo apt-get install -q -y compiz compiz-plugins compizconfig-settings-manager metacity dconf-tools > /dev/null
check_status

printf "Switch xfwm4 to compiz. Autostart compiz... "
#http://www.webupd8.org/2012/11/how-to-set-up-compiz-in-xubuntu-1210-or.html
cp /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml && \
 sed -i "s/xfwm4/compiz/" ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
check_status

printf "Setting the windows manager enviroment... "
# Close/minimize/maximize button not appearing
 DISPLAY=:0.0 gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close,' && \
 DISPLAY=:0.0 gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Droid Sans Bold 10' && \
# list of themes: /usr/share/themes/
 DISPLAY=:0.0 gsettings set org.gnome.desktop.wm.preferences theme 'Greybird'
check_status

printf "Installing plugins for Desktop Enviroment... "
sudo apt-get install -q -y xfce4-clipman-plugin xfce4-datetime-plugin xfce4-time-out-plugin > /dev/null
check_status

printf "Installing DockbarX (side-panel) ... "
# http://www.webupd8.org/2013/03/dockbarx-available-as-xfce-panel-plugin.html
# if you want preview: install compiz and add KDE compability
sudo add-apt-repository -y ppa:dockbar-main/ppa &> /dev/null && \
 sudo apt-get update > /dev/null && \
 sudo apt-get install -q -y --no-install-recommends xfce4-dockbarx-plugin > /dev/null
check_status

printf "Adding to autostart DockbarX ... "
sudo sh -c 'cat <<-EOF > /etc/xdg/autostart/dockx.desktop
[Desktop Entry]
Encoding=UTF-8
Name=dockx
Comment=dockx
Exec=dockx
Type=Application
EOF'
check_status

printf "Installing System Load Indicator for Desktop Enviroment... "
sudo add-apt-repository -y ppa:indicator-multiload/stable-daily &> /dev/null && \
 sudo apt-get update > /dev/null && \
 sudo apt-get install -q -y indicator-multiload > /dev/null && \
check_status

printf "Allow hibirnate... "
sudo awk -i inplace '{if ($0 == "[Disable hibernate by default in upower]" || $0 == "[Disable hibernate by default in logind]") { found=1 }; if (found == 1 && $0 ~ /^ResultActive=.*/) {print "ResultActive=yes"; found=0} else {print $0};}' /var/lib/polkit-1/localauthority/10-vendor.d/com.ubuntu.desktop.pkla
check_status

echo "Export settings"
exportlist="xfce4 compiz-1 autostart dconf Mousepad Thunar"
# xfce4     --general settings of Desktop Enviroment. Thunar settings.
# compiz-1  --settings of compiz
# autostart --autostart of System Load Indicator
# dconf     --settings of System Load Indicator plugin
# Mousepad  --hotkeys
# Thunar    --
for cur in $exportlist; do
  printf "\t of $cur... "
  rm -Rf ~/.config/$cur && cp -Rf $dir_data/config/$cur ~/.config/
  check_status
done
# settings of DockbarX
printf "\t of DockbarX... "
rm -Rf ~/.gconf && cp -Rf $dir_data/gconf ~/.gconf
check_status

echo
printf "Installing sysbench... "
sudo apt-get install -q -y sysbench > /dev/null
check_status
echo "Start 'sysbench --test=cpu run':"
echo "================================================"
sysbench --test=cpu run
echo "================================================"

echo
reboot_request
#printf "Relogin... "
#sudo service lightdm restart

