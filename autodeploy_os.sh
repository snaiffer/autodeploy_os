#!/bin/bash

echo "To leave settings as in example - just press <Enter>"
echo

export dir_script=`dirname $0`
export dir_data="$dir_script/data"
export bin="/usr/bin"

export git_email="snaiffer@gmail.com"
export git_name="Alexander Danilov"
echo "Git settings:"
printf "\temail ($git_email):"
read temp; if [[ "$temp" != "" ]]; then export git_email=$temp; fi
printf "\tname ($git_name):"
read temp; if [[ "$temp" != "" ]]; then export git_name=$temp; fi

# find out links for a newer version https://www.virtualbox.org/wiki/Downloads
export virtualbox_version='5.0'
export virtualbox_extenpack_link='http://download.virtualbox.org/virtualbox/5.0.14/Oracle_VM_VirtualBox_Extension_Pack-5.0.14-105127.vbox-extpack'
export virtualbox_extenpack_file='Oracle_VM_VirtualBox_Extension_Pack'

export wine_version='1.8-amd64'

# auth. for sudo
sudo echo

printf "Install & Set git... "
sudo apt-get install -q -y git > /dev/null && \
git config --global user.email $git_email && \
git config --global user.name $git_name && \
git config --global push.default matching   # push all branches
# git config --global push.default simple   # push the current branch only
if [[ "$?" != "0" ]]; then
  printf "There are some errors. Do you want to continue? ( y/n )... " && read answer
  if [[ "y" != "$answer" && "yes" != "$answer" ]]; then
    echo "exit"
    exit 1
  fi
  echo "continue"
fi
echo "done."

printf "Intalling libraries for bash... "
sudo git clone -q https://github.com/snaiffer/lib_bash_general.git /usr/lib/lib_bash_general && \
source /usr/lib/lib_bash_general/lib_bash_general.sh
check_status

printf "Creating dirs... "
mkdir -p ~/git ~/temp ~/VM_share &> /dev/null
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
sudo add-apt-repository -y ppa:schot/gawk &> /dev/null && sudo apt-get update > /dev/null && sudo apt-get install -q -y gawk > /dev/null && \
sudo apt-get install -q -y traceroute nethogs > /dev/null && \
sudo apt-get install -q -y expect > /dev/null && \
sudo apt-get install -q -y alien > /dev/null && \
sudo apt-get install -q -y vim openssh-server openssh-client tree nmap iotop htop foremost sshfs powertop &> /dev/null
check_status
printf "markdown terminal viewer... "
sudo apt install -q -y python2.7 python-pip > /dev/null && \
sudo pip install markdown pygments pyyaml > /dev/null && \
sudo git clone -q https://github.com/axiros/terminal_markdown_viewer $bin/terminal_markdown_viewer
check_status
echo -e "ssh settings:"
printf "\t turn off GSS for fast connection... "
sudo sh -c 'echo "GSSAPIAuthentication no" >> /etc/ssh/ssh_config'
check_status
printf "\t setting for keeping connection ~/.ssh... "
mkdir ~/.ssh
cat <<-EOF > ~/.ssh/config
Host *
ControlMaster auto
ControlPath ~/.ssh/cm_%r@%h:%p
EOF
check_status
echo "for WWW:"
printf "\tBrowser, torrent-client... "
sudo apt-get install -q -y transmission chromium-browser > /dev/null
check_status
printf "\tPepper Flash Player... "
sudo add-apt-repository -y ppa:skunk/pepper-flash &> /dev/null && \
sudo apt-get update > /dev/null && sudo apt-get install -q -y pepflashplugin-installer &> /dev/null && \
sudo sh -c 'echo ". /usr/lib/pepflashplugin-installer/pepflashplayer.sh" >> /etc/chromium-browser/default' > /dev/null
# to check if it has been success:
## open chromium and input "chrome://plugins" in the address line
check_status
printf "for systems... "
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && \
  sudo apt-get install -q -y terminator mtp-tools mtpfs pavucontrol ubuntu-restricted-extras &> /dev/null
check_status
echo "for VirtualBox:"
sudo sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian `lsb_release -cs` contrib' >> /etc/apt/sources.list" && \
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add - > /dev/null && \
sudo apt-get update > /dev/null && sudo apt-get install -q -y virtualbox-$virtualbox_version > /dev/null
check_status
printf "\tVirtualBox Extension Pack... "
wget -q $virtualbox_extenpack_link && \
sudo VBoxManage extpack install ${virtualbox_extenpack_file}* &> /dev/null && \
rm -f ${virtualbox_extenpack_file}*
check_status
printf "for libreoffice... "
sudo apt-get install -q -y libreoffice &> /dev/null
check_status
printf "for wine likes programs... "
sudo add-apt-repository -y ppa:ubuntu-wine/ppa &> /dev/null && sudo apt-get update > /dev/null && \
sudo apt-get install -q -y wine$wine_version playonlinux &> /dev/null
check_status
printf "for images... "
sudo apt-get install -q -y gimp pinta &> /dev/null && \
# https://github.com/cas--/PasteImg
sudo cp -f $dir_data/pasteimg $bin && sudo chmod +x $bin/pasteimg
check_status
printf "for media... "
sudo apt-get install -q -y gnome-mplayer vlc &> /dev/null
check_status
printf "for tlp (power saving utils)..."
sudo add-apt-repository -y ppa:linrunner/tlp &> /dev/null && sudo apt-get update > /dev/null && \
sudo apt-get install -q -y tlp tlp-rdw smartmontools ethtool linux-tools-`uname -r` &> /dev/null
check_status
printf "for others... "
sudo apt-get install -q -y basket k3b unetbootin &> /dev/null
check_status
# libreoffice doesn't support muilti-spellcheching
#printf "plugins for LibreOffice... "
#export libreoffice_languagetools='https://www.languagetool.org/download/LanguageTool-3.0.oxt'
#dir_download=/tmp/libreoffice_plugins && \
#  mkdir $dir_download && \
#  wget -q $libreoffice_languagetools http://extensions.libreoffice.org/extension-center/russian-spellcheck-dictionary.-based-on-works-of-aot-group/pscreleasefolder.2011-09-06.6209385965/0.4.0/dict_ru_ru-aot-0-4-0.oxt -P $dir_download && \
#  rm -Rf $dir_download
#check_status

echo
printf "Installing drivers... "
sudo ubuntu-drivers autoinstall > /dev/null
check_status

echo
printf "Installing utils for C++ programming... "
sudo add-apt-repository -y ppa:george-edison55/cmake-3.x &> /dev/null && \
 sudo apt-get update > /dev/null && \
sudo apt-get install -q -y g++ valgrind doxygen cmake gdb clang &> /dev/null
check_status

echo
printf "Set keyboardlayout switcher by Caps key... "
sudo sed -i "s/XKBOPTIONS=\"/XKBOPTIONS=\"grp:caps_toggle\,/" /etc/default/keyboard
## work on HP Pavilion laptop with Lubuntu
#sudo cp -f $dir_data/keyboardlayout_switcher.desktop /etc/xdg/autostart/
check_status

printf "Clone syncfrom... "
mkdir -p ~/git/ && \
git clone -q https://github.com/snaiffer/syncfrom.git ~/git/syncfrom/
check_status

printf "Setting bash enviroment... "
git clone -q https://github.com/snaiffer/bash_env.git ~/.bash_env && \
sudo ~/.bash_env/install.sh > /dev/null
check_status

printf "Setting vim... "
sudo apt-get install -q -y vim git ctags clang libclang-dev > /dev/null && \
rm -Rf ~/.vim ~/.vimrc && \
git clone -q https://github.com/snaiffer/vim.git ~/.vim && \
ln -s ~/.vim/vimrc ~/.vimrc && \
vim -c "BundleInstall" -c 'qa!'
check_status

printf "Installing git-meld... "
sudo apt-get install -q -y meld &> /dev/null && \
# https://github.com/wmanley/git-meld
sudo cp -f $dir_data/git-meld.pl $bin && sudo chmod +x $bin/git-meld.pl && \
echo "[alias]
  meld = !$bin/git-meld.pl" >> ~/.gitconfig
check_status

printf "Turn off apport... "
sudo sed -i "s/enabled=1/enabled=0/" /etc/default/apport
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
 sudo apt-get install -q -y indicator-multiload > /dev/null
check_status

printf "Installing Windowck Plugin for moving titlebar to panel... "
sudo add-apt-repository -y ppa:eugenesan/ppa &> /dev/null && \
 sudo apt-get update > /dev/null && \
 sudo apt-get install -q -y xfce4-windowck-plugin maximus > /dev/null && \
 gconftool-2 --set /apps/maximus/no_maximize --type=bool true
check_status

printf "Installing local dictionary for xfce plugin... "
sudo apt-get install -q -y dictd xfce4-dict mueller7accent-dict > /dev/null
check_status

printf "Allow hibirnate... "
sudo awk -i inplace '{if ($0 == "[Disable hibernate by default in upower]" || $0 == "[Disable hibernate by default in logind]") { found=1 }; if (found == 1 && $0 ~ /^ResultActive=.*/) {print "ResultActive=yes"; found=0} else {print $0};}' /var/lib/polkit-1/localauthority/10-vendor.d/com.ubuntu.desktop.pkla
check_status

echo "Export settings"
printf "\t of background... "
p="/usr/share/xfce4/backdrops"
sudo mkdir -p $p &> /dev/null && \
sudo cp -f $dir_data/solitude.jpg $p
check_status
#exportlist="xfce4 compiz-1 autostart dconf Mousepad Thunar terminator xfce4-dict"
exportlist="xfce4 compiz-1 autostart Mousepad Thunar terminator xfce4-dict"
# xfce4     --general settings of Desktop Enviroment. Thunar settings.
# compiz-1  --settings of compiz
# autostart --autostart of System Load Indicator

## dconf     --settings of System Load Indicator plugin <= it is loaded from dump now (test mode)
## remove dconf dir from data_dir, when it will be tested

# Mousepad  --hotkeys
# Thunar    --
# terminator -- settings of Terminator
# xfce4-dict -- settings for dictionary
for cur in $exportlist; do
  printf "\t of $cur... "
  rm -Rf ~/.config/$cur && cp -Rf $dir_data/config/$cur ~/.config/ && \
    find ~/.config/$cur -type f -print0 | xargs -0 sed "s/snaiffer/$SUDO_USER/g"
  check_status
done
printf "\t of DockbarX... "
rm -Rf ~/.gconf && cp -Rf $dir_data/gconf ~/.gconf && \
  find ~/.gconf -type f -print0 | xargs -0 sed "s/snaiffer/$SUDO_USER/g"
check_status
printf "\t of Preferred Applications... "
mkdir -p ~/.local/share/xfce4 && \
cp -Rf $dir_data/helpers ~/.local/share/xfce4/ && \
  find ~/.local/share/xfce4/helpers -type f -print0 | xargs -0 sed "s/snaiffer/$SUDO_USER/g"
check_status
printf "\t of System load indicator... "
sudo cp $dir_data/indicator-multiload-settings /usr/bin/ && \
  sudo chmod +x /usr/bin/indicator-multiload-settings
# by hand:
## cat $dir_data/system_load_indicator.dconf.dump | dconf load /de/mh21/indicator-multiload/
check_status

echo
printf "Settings for Background... "
rm -f ~/.config/xfce4/desktop/* > /dev/null
check_status

if [[ `terminator -v  | sed "s/terminator //"` < 0.97 ]]; then
  echo
  printf "\t bug fix for Terminator with keybind... "
  sudo patch /usr/share/terminator/terminatorlib/container.py < $dir_data/terminator_close_multiterminals_withoutconfirm.patch > /dev/null
  check_status
fi

echo
printf "Fixing bug with xfce-sessions... "
# Even if sessions are turn off xfce make them and it follow to bugs of Desktop after reboot
rm -f ~/.cache/sessions/* > /dev/null && \
chmod -w ~/.cache/sessions
check_status

echo
printf "Fixing bug with network... "
sudo cp -f $dir_data/55_local_networkmanager /etc/pm/sleep.d/55_local_networkmanager && \
  chmod +x /etc/pm/sleep.d/55_local_networkmanager && \
check_status

echo
printf "Fixing bug with Lenovo IdeaPad Yoga 13... "
# /var/log/syslog: atkbd serio0: Unknown key released (translated set 2, code 0xbe on isa0060/serio0)
# kernel: [57478.570447] atkbd serio0: Use 'setkeycodes e03e <keycode>' to make it known
sudo dmidecode |grep 'Lenovo IdeaPad Yoga 13' && sudo setkeycodes e03e 255
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
echo "Foxit Reader PDF (very fast and pretty)"
echo "You can download and install it manually. Go to:"
echo "https://www.foxitsoftware.com/downloads/"
echo "<Enter>" && read

echo
echo -e "MS Office
- Mount the disk with MS_Office
    $ sudo mount -o loop ./<MS_Office>.iso /mnt/
- Install MS_Office throught PlayOnLinux
- Associate formats: doc... xls... with PlayOnLinux
    Go to PlayOnLinux options -> Settings/File associations (.docx -> Microsoft Word 2010)
    You need to enter separately each file type (xls,xlsx,dox,docx) and to associate it with the corresponding office program.
  .doc
  .docx
  .xls
  .xlsx
  .ppt
  .pptx
- Change associative commands
    $ sudo cp $dir_data/ms_office_associations/* /usr/share/applications/
"
echo "<Enter>" && read

echo
echo -e "Background settings
Execute after reboot:"
echo '  sed -i "/last-image/,/$/ s/value=\".*\"/value=\"\/usr\/share\/xfce4\/backdrops\/solitude\.jpg\"/" ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml'
echo '  sudo reboot'
echo "<Enter>" && read


echo
reboot_request
#printf "Relogin... "
#sudo service lightdm restart

