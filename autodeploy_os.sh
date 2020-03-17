#!/bin/bash

echo "To leave settings as in example - just press <Enter>"
echo

export dir_script=`dirname $0`
export dir_data="$dir_script/data"
export bin="/usr/bin"

export git_email="a.danilov@runabank.ru"
export git_name="Alexander Danilov"
echo "Git settings:"
printf "\temail ($git_email):"
read temp; if [[ "$temp" != "" ]]; then export git_email=$temp; fi
printf "\tname ($git_name):"
read temp; if [[ "$temp" != "" ]]; then export git_name=$temp; fi

# find out links for a newer version https://www.virtualbox.org/wiki/Downloads
#export virtualbox_extenpack_link='https://download.virtualbox.org/virtualbox/5.2.12/Oracle_VM_VirtualBox_Extension_Pack-5.2.12.vbox-extpack'
#export virtualbox_extenpack_file='Oracle_VM_VirtualBox_Extension_Pack'

export hamachi_link='https://www.vpn.net/installers/logmein-hamachi_2.1.0.165-1_amd64.deb'

export java_version='java8'

# auth. for sudo
sudo echo

printf "Install & Set git... "
sudo apt-get install -q -y git && \
git config --global user.email $git_email && \
git config --global user.name $git_name && \
git config --global push.default matching   # push all branches
# git config --global push.default simple   # push the current branch only
git config --global diff.submodule log  # get info about changes in submodules with help of "git diff"
git config --global diff.tool meld
git config --global merge.tool meld
if [[ "$?" != "0" ]]; then
  printf "${b}There are some errors. Do you want to continue? ( y/n )... ${n}" && read answer
  if [[ "y" != "$answer" && "yes" != "$answer" ]]; then
    echo "exit"
    exit 1
  fi
  echo "continue"
fi
echo "done."

printf "Intalling libraries for bash... "
sudo git clone -q https://github.com/snaiffer/libbash.git /usr/lib/bash && \
source /usr/lib/bash/general.sh
check_status

printf "${b}Creating dirs... ${n}"
mkdir -p ~/git ~/temp ~/VM_share > /dev/null
check_status

#printf "${b}Set Desktop count... ${n}"
#echo "${b}Run obconf and go to Desktop${n}"
#obconf
#check_status

#printf "${b}Set screen brightness... ${n}"
## https://linuxcritic.wordpress.com/2015/03/29/change-screen-brightness-in-lxde/
## xrandr -q | grep connected
#xrandr --output LVDS --brightness 0.9
#check_status

echo
printf "${b}Removing packages... ${n}"
sudo apt-get remove -q -y abiword* gnumeric* xfburn parole gmusicbrowser xfce4-notes firefox xfce4-terminal > /dev/null
check_status

echo
echo "${b}Installing packages:${n}"
sudo apt-get update > /dev/null
printf "${b}for console... ${n}"
sudo apt-get install -q -y gawk && \
sudo apt-get install -q -y traceroute nethogs whois && \
sudo apt-get install -q -y expect && \
sudo apt-get install -q -y alien && \
#sudo apt-get install -q -y jq && \  # pretty json output # TODO: add repo for it
sudo apt-get install -q -y vim && \
sudo apt-get install -q -y vim-gui-common && \  # GUI features. Don't install it on a server
sudo apt-get install -q -y openssh-server openssh-client tree nmap iotop htop foremost sshfs powertop bless apt-file
check_status
printf "${b}markdown terminal viewer... ${n}"
sudo apt-get install -q -y python2.7 python-pip && \
pip install markdown pygments pyyaml && \
sudo git clone -q https://github.com/axiros/terminal_markdown_viewer $bin/terminal_markdown_viewer && \
sudo ln -s $bin/terminal_markdown_viewer/mdv/markdownviewer.py $bin/mdv
check_status
echo -e "${b}ssh settings:${n}"
printf "${b}\t turn off GSS for fast connection... ${n}"
sudo sh -c 'echo "GSSAPIAuthentication no" >> /etc/ssh/ssh_config'
check_status
printf "${b}\t setting for keeping connection ~/.ssh... ${n}"
mkdir ~/.ssh
cat <<-EOF > ~/.ssh/config
Host *
ControlMaster auto
ControlPath ~/.ssh/cm_%r@%h:%p
EOF
check_status
printf "${b}for systems... ${n}"
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && \
  sudo apt-get install -q -y terminator mtp-tools mtpfs pavucontrol ubuntu-restricted-extrasl
check_status
echo "${b}for WWW:${n}"
printf "${b}\tset chromium-browser by default... ${n}"
sudo sed -i "s/firefox.desktop/chromium-browser.desktop/g" /usr/share/applications/defaults.list
check_status
# for 14.04
#printf "${b}\tPepper Flash Player... ${n}"
#sudo add-apt-repository -y ppa:skunk/pepper-flash > /dev/null && \
#sudo apt-get update > /dev/null && sudo apt-get install -q -y pepflashplugin-installerl && \
#sudo sh -c 'echo ". /usr/lib/pepflashplugin-installer/pepflashplayer.sh" >> /etc/chromium-browser/default' > /dev/null
## to check if it has been success:
### open chromium and input "chrome://plugins" in the address line
printf "${b}\tFlash Player... ${n}"
sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner" > /dev/null && \
sudo apt-get update > /dev/null && sudo apt-get install -q -y adobe-flashplugin browser-plugin-freshplayer-pepperflashl
check_status
printf "${b}\tchrome-browser... ${n}"
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && \
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
sudo apt-get update > /dev/null && \
sudo apt-get install -q -y google-chrome-stablel
check_status
printf "${b}\tJava... ${n}"
sudo add-apt-repository -y ppa:webupd8team/java > /dev/null && \
sudo apt-get update > /dev/null && sudo apt-get install -q -y oracle-$java_version-installer && \
check_status
echo "${b}for VirtualBox:${n}"
sudo sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian `lsb_release -cs` contrib' >> /etc/apt/sources.list.d/virtualbox.list" && \
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add - && \
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add - && \
sudo apt-get update > /dev/null && sudo apt-get install -q -y virtualbox
check_status
#printf "${b}\tVirtualBox Extension Pack... ${n}"
#wget -q $virtualbox_extenpack_link && \
#sudo VBoxManage extpack install ${virtualbox_extenpack_file}* && \
#rm -f ${virtualbox_extenpack_file}*
#check_status
printf "${b}for libreoffice... ${n}"
sudo apt-get install -q -y libreoffice
check_status
printf "${b}for wireshark... ${n}"
sudo add-apt-repository -y ppa:wireshark-dev/stable > /dev/null && sudo apt-get update > /dev/null && \
sudo apt-get install -q -y wireshark
check_status
#printf "${b}for wine likes programs... ${n}"
# install wine: https://wiki.winehq.org/Ubuntu
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E0F72778C4676186 && \
#sudo wget http://deb.playonlinux.com/playonlinux_trusty.list -O /etc/apt/sources.list.d/playonlinux.list && \
#sudo apt-get update > /dev/null && sudo apt-get install -q -y playonlinux 
#check_status
printf "${b}for images... ${n}"
sudo apt-get install -q -y gimp pinta gthumb && \
# https://github.com/cas--/PasteImg
sudo cp -f $dir_data/pasteimg $bin && sudo chmod +x $bin/pasteimg
check_status
printf "${b}for media... ${n}"
sudo apt-get install -q -y vlc
# for 14.04
#sudo apt-get install -q -y gnome-mplayer
check_status
printf "${b}for tlp (power saving utils)...${n}"
sudo add-apt-repository -y ppa:linrunner/tlp > /dev/null && sudo apt-get update > /dev/null && \
sudo apt-get install -q -y tlp tlp-rdw smartmontools ethtool linux-tools-`uname -r`
check_status
printf "${b}for others... ${n}"
#for 14.04
#sudo apt-get install -q -y unetbootin
sudo apt-get install -q -y basket baobab k3b meld
check_status
# libreoffice doesn't support muilti-spellcheching
#printf "${b}plugins for LibreOffice... ${n}"
#export libreoffice_languagetools='https://www.languagetool.org/download/LanguageTool-3.0.oxt'
#dir_download=/tmp/libreoffice_plugins && \
#  mkdir $dir_download && \
#  wget -q $libreoffice_languagetools http://extensions.libreoffice.org/extension-center/russian-spellcheck-dictionary.-based-on-works-of-aot-group/pscreleasefolder.2011-09-06.6209385965/0.4.0/dict_ru_ru-aot-0-4-0.oxt -P $dir_download && \
#  rm -Rf $dir_download
#check_status

echo
printf "${b}Forward copy/paste-buffer via ssh... ${n}"
sudo apt-get install -q -y xclip && \
  echo "ForwardX11 yes" >> ~/.ssh/config
check_status

echo
printf "${b}Installing drivers... ${n}"
sudo ubuntu-drivers autoinstall > /dev/null
check_status

echo
printf "${b}Installing utils for C++ programming... ${n}"
# for 14.04
#sudo add-apt-repository -y ppa:george-edison55/cmake-3.x > /dev/null && \
# sudo apt-get update > /dev/null && \
sudo apt-get install -q -y g++ valgrind doxygen cmake gdb clang
check_status

echo
printf "${b}Set keyboardlayout switcher by Caps key... ${n}"
sudo sed -i "s/XKBOPTIONS=\"/XKBOPTIONS=\"grp:caps_toggle\,/" /etc/default/keyboard
## work on HP Pavilion laptop with Lubuntu
#sudo cp -f $dir_data/keyboardlayout_switcher.desktop /etc/xdg/autostart/
check_status

#echo
#printf "${b}Installing and setting Hamachi VPN network... ${n}"
#sudo wget -q $hamachi_link -P /tmp/ && \
#  sudo dpkg -i /tmp/logmein-hamachi_*.deb > /dev/null && \
#  sudo hamachi login && \
#  sudo hamachi set-nick `uname -n` && \
#  echo "Join to snaifvpn..." && \
#  sudo hamachi join snaifvpn && \
#  sudo hamachi list
#check_status

printf "${b}Clone syncfrom... ${n}"
mkdir -p ~/git/ && \
git clone -q https://github.com/snaiffer/syncfrom.git ~/git/syncfrom/
check_status

printf "${b}Setting bash enviroment... ${n}"
git clone -q https://github.com/snaiffer/bash_env.git ~/.bash_env && \
sudo ~/.bash_env/install.sh > /dev/null
check_status

printf "${b}Setting vim... ${n}"
sudo apt-get install -q -y vim git ctags clang libclang-dev && \
rm -Rf ~/.vim ~/.vimrc && \
git clone -q https://github.com/snaiffer/vim.git ~/.vim && \
ln -s ~/.vim/vimrc ~/.vimrc && \
vim -c "BundleInstall" -c 'qa!' && \
~/.vim/bundle/youcompleteme
check_status

printf "${b}Turn off apport... ${n}"
sudo sed -i "s/enabled=1/enabled=0/" /etc/default/apport
check_status

echo
echo "${b}Setting Desktop Enviroment${n}"
printf "${b}Installing compiz (windows manager)... ${n}"
sudo apt-get install -q -y compiz compiz-plugins compizconfig-settings-manager metacity dconf-tools
check_status

printf "${b}Switch xfwm4 to compiz. Autostart compiz... ${n}"
#http://www.webupd8.org/2012/11/how-to-set-up-compiz-in-xubuntu-1210-or.html
cp /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml && \
 sed -i "s/xfwm4/compiz/" ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
check_status

printf "${b}Setting the windows manager enviroment... ${n}"
# Close/minimize/maximize button not appearing
 DISPLAY=:0.0 gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close,' && \
 DISPLAY=:0.0 gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Droid Sans Bold 10' && \
# list of themes: /usr/share/themes/
 DISPLAY=:0.0 gsettings set org.gnome.desktop.wm.preferences theme 'Greybird'
check_status

printf "${b}Installing plugins for Desktop Enviroment... ${n}"
sudo apt-get install -q -y xfce4-clipman-plugin xfce4-datetime-plugin xfce4-time-out-plugin
check_status

# there isn't version for 18.04
#printf "${b}Installing DockbarX (side-panel) ... ${n}"
## http://www.webupd8.org/2013/03/dockbarx-available-as-xfce-panel-plugin.html
## if you want preview: install compiz and add KDE compability
#sudo add-apt-repository -y ppa:dockbar-main/ppa > /dev/null && \
# sudo apt-get update > /dev/null && \
# sudo apt-get install -q -y --no-install-recommends xfce4-dockbarx-plugin
#check_status
#
#printf "${b}Adding to autostart DockbarX ... ${n}"
#sudo sh -c 'cat <<-EOF > /etc/xdg/autostart/dockx.desktop
#[Desktop Entry]
#Encoding=UTF-8
#Name=dockx
#Comment=dockx
#Exec=dockx
#Type=Application
#EOF'
#check_status
#
#printf "${b}Installing System Load Indicator for Desktop Enviroment... ${n}"
#sudo add-apt-repository -y ppa:indicator-multiload/stable-daily > /dev/null && \
# sudo apt-get update > /dev/null && \
# sudo apt-get install -q -y indicator-multiload
#check_status
#
#printf "${b}Installing Windowck Plugin for moving titlebar to panel... ${n}"
#sudo add-apt-repository -y ppa:eugenesan/ppa > /dev/null && \
# sudo apt-get update > /dev/null && \
# sudo apt-get install -q -y xfce4-windowck-plugin maximus && \
# gconftool-2 --set /apps/maximus/no_maximize --type=bool true
#check_status

#printf "${b}Installing local dictionary for xfce plugin... ${n}"
#sudo apt-get install -q -y dictd xfce4-dict mueller7accent-dict
#check_status

#printf "${b}Allow hibirnate... ${n}"
#sudo awk -i inplace '{if ($0 == "[Disable hibernate by default in upower]" || $0 == "[Disable hibernate by default in logind]") { found=1 }; if (found == 1 && $0 ~ /^ResultActive=.*/) {print "ResultActive=yes"; found=0} else {print $0};}' /var/lib/polkit-1/localauthority/10-vendor.d/com.ubuntu.desktop.pkla
#check_status

echo "${b}Export settings${n}"
printf "${b}\t of background... ${n}"
p="/usr/share/xfce4/backdrops"
sudo mkdir -p $p > /dev/null && \
sudo cp -f $dir_data/solitude.jpg $p
check_status
#exportlist="xfce4 compiz-1 autostart dconf Mousepad Thunar terminator xfce4-dict"
#exportlist="xfce4 compiz-1 autostart Mousepad Thunar terminator xfce4-dict"
exportlist="xfce4 compiz-1 Mousepad Thunar terminator"
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
  printf "${b}\t of $cur... ${n}"
  rm -Rf ~/.config/$cur && cp -Rf $dir_data/config/$cur ~/.config/ && \
    find ~/.config/$cur -type f -print0 | xargs -0 sed "s/snaiffer/$SUDO_USER/g"
  check_status
done
#printf "${b}\t of DockbarX... ${n}"
#rm -Rf ~/.gconf && cp -Rf $dir_data/gconf ~/.gconf && \
#  find ~/.gconf -type f -print0 | xargs -0 sed "s/snaiffer/$SUDO_USER/g"
#check_status
printf "${b}\t of Preferred Applications... ${n}"
mkdir -p ~/.local/share/xfce4 && \
cp -Rf $dir_data/helpers ~/.local/share/xfce4/ && \
  find ~/.local/share/xfce4/helpers -type f -print0 | xargs -0 sed "s/snaiffer/$SUDO_USER/g"
check_status
#printf "${b}\t of System load indicator... ${n}"
#sudo cp $dir_data/indicator-multiload-settings /usr/bin/ && \
#  sudo chmod +x /usr/bin/indicator-multiload-settings
# by hand:
## cat $dir_data/system_load_indicator.dconf.dump | dconf load /de/mh21/indicator-multiload/
#check_status

echo
printf "${b}Settings for Background... ${n}"
rm -f ~/.config/xfce4/desktop/* > /dev/null
check_status

if [[ `terminator -v  | sed "s/terminator //"` < 0.97 ]]; then
  echo
  printf "${b}\t bug fix for Terminator with keybind... ${n}"
  sudo patch /usr/share/terminator/terminatorlib/container.py < $dir_data/terminator_close_multiterminals_withoutconfirm.patch > /dev/null
  check_status
fi

echo
printf "${b}Fixing bug with xfce-sessions... ${n}"
# Even if sessions are turn off xfce make them and it follow to bugs of Desktop after reboot
rm -f ~/.cache/sessions/* > /dev/null && \
chmod -w ~/.cache/sessions
check_status

# it isn't actual for kernel < 4.9
#echo
#printf "${b}Fixing bug with network... ${n}"
#sudo cp -f $dir_data/wifi_unfreeze /bin/ && \
#  chmod +x /bin/wifi_unfreeze && \
#sudo cp -f $dir_data/55_local_networkmanager /etc/pm/sleep.d/55_local_networkmanager && \
#  chmod +x /etc/pm/sleep.d/55_local_networkmanager
#check_status

echo
printf "${b}Fixing 'Open with other application...' saving chose... ${n}"
if [ -d ~/.local/share/applications ]; then
  # back up file application. For what is its file?
  mv ~/.local/share/applications ~/.local/share/applications.bac > /dev/null && \
  mkdir -p ~/.local/share/applications > /dev/null
fi
check_status

echo
printf "${b}Fixing bug with Lenovo IdeaPad Yoga 13... ${n}"
# /var/log/syslog: atkbd serio0: Unknown key released (translated set 2, code 0xbe on isa0060/serio0)
# kernel: [57478.570447] atkbd serio0: Use 'setkeycodes e03e <keycode>' to make it known
sudo dmidecode |grep 'Lenovo IdeaPad Yoga 13' && sudo setkeycodes e03e 255
check_status

echo
printf "${b}Installing sysbench... ${n}"
sudo apt-get install -q -y sysbench
check_status
echo "${b}Start 'sysbench --test=cpu run':${n}"
echo "${b}================================================${n}"
sysbench --test=cpu run
echo "${b}================================================${n}"

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
#printf "${b}Relogin... ${n}"
#sudo service lightdm restart

