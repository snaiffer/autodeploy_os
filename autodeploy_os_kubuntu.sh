#!/bin/bash -xu
# -x    --print commands and their arguments as they are executed
# -e    --exit on error
# -u    --to treat unset variables as an error and exit immediately

dir_local="$(dirname $(readlink -f $0))"

##################################################################
# settings
export git_email="Alexander.Danilov@cma.ru"
export git_name="Alexander Danilov"

##################################################################

help() {
  cat <<-EOF
Script for auto-settinging OS enviroment after installation.

Syntax:
`basename $0` [<mode>]
  <mode>  --installation mode:
    desktop
    server
EOF
}

case "$1" in
  "desktop"|"server")
    mode="$1"
    ;;
  "-h"|"--help"|"help")
    help
    exit 0
    ;;
  *)
    echo "ERROR: parameter is required"
    echo
    help
    exit 1
esac

##################################################################

os_release_major=$(lsb_release -rs | sed 's/\..*$//')

# Example:
# printf "${b}my bold text${n}"
export b=$(tput bold)   # bold text
export n=$(tput sgr0)   # normal text
export yellow="\033[1;33;40m"   # yellow text

# Usefull:
# lsb_release -sc	# get codename (Ex.: bionic, xenial)
echo "To leave settings as in example - just press <Enter>"
echo

export dir_local=`dirname $0`
export dir_data="$dir_local/data"
export bin="/usr/bin"
export logd="$dir_local/progress_details_`date +%m%d_%H%M`.log"
echo "" > $logd
echo -e "\n${yellow}Detailed progress log you can get in: $logd ${n}\n"


echo "Git settings:"
printf "\temail ($git_email): "
read temp; if [[ "$temp" != "" ]]; then export git_email=$temp; fi
printf "\tname ($git_name): "
read temp; if [[ "$temp" != "" ]]; then export git_name=$temp; fi

function log()
{
  msg=$1
  echo -e "$(date "+%Y-%m-%d %T"): `basename $0`: $msg"
}
# usage: log "started"

# find out links for a newer version https://www.virtualbox.org/wiki/Downloads
#export virtualbox_extenpack_link='https://download.virtualbox.org/virtualbox/5.2.12/Oracle_VM_VirtualBox_Extension_Pack-5.2.12.vbox-extpack'
#export virtualbox_extenpack_file='Oracle_VM_VirtualBox_Extension_Pack'

#export hamachi_link='https://www.vpn.net/installers/logmein-hamachi_2.1.0.165-1_amd64.deb'

# auth. for sudo
sudo echo

printf "Install & Set git... "
sudo apt-get install -q -y git >> $logd && \
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
# Git: force to use SSH URL instead of HTTPS for github.com:
# git config --global url."git@github.com:".insteadOf "https://github.com/"
# Note: if you use HTTPS, you always have to input login&password
# With help of this settings you can copy your public key (.ssh/id_rsa.pub) to website account and work with repos without login
echo "done."

printf "Intalling libraries for bash... "
sudo git clone -q https://github.com/snaiffer/libbash.git /usr/lib/bash && \
cd /usr/lib/bash && sudo git remote set-url origin git@github.com:snaiffer/libbash.git && cd $OLDPWD && \
source /usr/lib/bash/general.sh
check_status

echo
# xev   --show key codes
if [[ "$mode" = "desktop" ]]; then
echo
printf "${b}Right Ctrl => End; Right Shift => Home; Right Alt => Right Ctrl... ${n}"
# xev   --show key codes
# xmodmap -pm   --show current modifier keys
# https://wiki.archlinux.org/title/Xmodmap
cat <<-EOF >> ~/.Xmodmap
! Shift_R => Home
clear shift
add shift = Shift_L
keycode 62 = Home Home Home Home Home Home Home

clear control
clear mod1
! Alt_R => Control_R
keycode 108 = Control_R Control_R Control_R Control_R Control_R Control_R Control_R
add control = Control_L Control_R
add mod1 = Alt_L Meta_L
! Control_R => End
keycode 105 = End End End End End End End
EOF
xmodmap ~/.Xmodmap
check_status
fi;

echo
printf "${b}Creating dirs... ${n}"
mkdir -p ~/git ~/temp ~/VM_share ~/payload > /dev/null
check_status

echo
printf "${b}Removing packages... ${n}"
sudo apt-get remove -q -y xfce4-screensaver abiword* gnumeric* xfburn parole gmusicbrowser xfce4-notes xfce4-terminal > /dev/null
check_status

echo
printf "${b}Installing drivers... ${n}"
sudo ubuntu-drivers autoinstall > /dev/null
check_status

echo
echo "${b}Installing packages:${n}"
sudo apt-get update > /dev/null
#############################################
printf "${b}for console... ${n}"
# jq              --pretty json output
# vim-gui-common  --GUI features. Don't install it on a server
sudo apt-get install -q -y jq >> $logd && \
sudo apt-get install -q -y libxml2-utils >> $logd && \
sudo apt-get install -q -y gawk icdiff >> $logd && \
sudo apt-get install -q -y net-tools traceroute nethogs whois >> $logd && \
sudo apt-get install -q -y expect >> $logd && \
sudo apt-get install -q -y alien >> $logd && \
sudo apt-get install -q -y vim >> $logd && \
( [[ "$mode" = "server" ]] || sudo apt-get install -q -y vim-gui-common >> $logd ) && \
sudo apt-get install -q -y openssh-server openssh-client tree nmap iotop htop foremost sshfs powertop bless curl >> $logd && \
sudo apt-get install -q -y apt-file >> $logd && \
  sudo apt-file update > /dev/null && \
sudo apt-get install -q -y unrar >> $logd && \
sudo apt-get install -q -y pwgen >> $logd && \
sudo apt-get install -q -y byobu >> $logd
check_status
#############################################
printf "${b}markdown terminal viewer... ${n}"
sudo apt-get install -q -y python2.7 python3-pip python3-virtualenv >> $logd && \
pip3 install -q markdown pygments pyyaml >> $logd
check_status
#sudo git clone -q https://github.com/axiros/terminal_markdown_viewer $bin/terminal_markdown_viewer && \
#sudo ln -s $bin/terminal_markdown_viewer/mdv/markdownviewer.py $bin/mdv
#############################################
echo -e "${b}ssh settings:${n}"
# without prompt
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
printf "${b}\t ssh-server setting... ${n}"
sudo sh -c "echo 'PermitRootLogin no' >> /etc/ssh/sshd_config"
check_status
printf "${b}\t turn off GSS for fast connection... ${n}"
sudo sh -c 'echo "GSSAPIAuthentication no" >> /etc/ssh/ssh_config'
check_status
printf "${b}\t setting for keeping connection ~/.ssh... ${n}"
mkdir -p ~/.ssh
cat <<-EOF > ~/.ssh/config
Host *
ControlMaster auto
ControlPath ~/.ssh/cm_%r@%h:%p
EOF
check_status
if [[ "$mode" = "server" ]]; then
  #############################################
  printf "${b}\t fail2ban (bruteforce protection)... ${n}"
  sudo apt-get install -q -y fail2ban >> $logd && \
  sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
:<<-EOF
  Edit in [DEFAULT] section:
    bantime = 1h
    maxretry = 3
EOF
  sudo service fail2ban restart
  check_status
fi

if [[ "$mode" = "desktop" ]]; then
  #############################################
  printf "${b}for systems... ${n}"
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && \
    sudo apt-get install -q -y mtp-tools go-mtpfs >> $logd
  check_status
  #sudo apt-get install -q -y terminator pavucontrol >> $logd
  #############################################
  echo "${b}for WWW:${n}"
  # for 14.04
  #printf "${b}\tPepper Flash Player... ${n}"
  #sudo add-apt-repository -y ppa:skunk/pepper-flash > /dev/null && \
  #sudo apt-get update > /dev/null && sudo apt-get install -q -y pepflashplugin-installer >> $logd && \
  #sudo sh -c 'echo ". /usr/lib/pepflashplugin-installer/pepflashplayer.sh" >> /etc/chromium-browser/default' > /dev/null
  ## to check if it has been success:
  ### open chromium and input "chrome://plugins" in the address line
  #printf "${b}\tFlash Player... ${n}"
  #sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner" > /dev/null && \
  #sudo apt-get update > /dev/null && sudo apt-get install -q -y adobe-flashplugin browser-plugin-freshplayer-pepperflash >> $logd
  #check_status
  #############################################
  printf "${b}\tchrome-browser... ${n}"
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && \
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
  sudo apt-get update > /dev/null && \
  sudo apt-get install -q -y google-chrome-stable >> $logd
  check_status
  printf "${b}\tset google-chrome by default... ${n}"
  sudo sed -i "s/firefox.desktop/google-chrome.desktop/g" /usr/share/applications/defaults.list
  check_status
  #############################################
  #printf "${b}\tfirefox-browser... ${n}"
  #sudo apt-get install -q -y firefox >> $logd
  #check_status
  #printf "${b}\tset firefox by default... ${n}"
  #sudo sed -i "s/google-chrome.desktop/firefox.desktop/g" /usr/share/applications/defaults.list
  #check_status
  #############################################
  #printf "${b}\tJava... ${n}"
  #sudo add-apt-repository -y ppa:webupd8team/java > /dev/null && \
  #sudo apt-get update > /dev/null && sudo apt-get install -q -y oracle-java8-installer >> $logd
  #check_status
  #############################################
  echo "${b}for VirtualBox:${n}"
  sudo sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian `lsb_release -cs` contrib' >> /etc/apt/sources.list.d/virtualbox.list" && \
  wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add - && \
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add - && \
  sudo apt-get update > /dev/null && sudo apt-get install -y virtualbox virtualbox-dkms virtualbox-ext-pack # -q and >> $logd were commented as the installation process wants actions in firmware sign menu
  check_status
  #Another way for virtualbox-ext-pack:
  # printf "${b}\tVirtualBox Extension Pack... ${n}"
  # wget -q $virtualbox_extenpack_link && \
  # sudo VBoxManage extpack install ${virtualbox_extenpack_file}* && \
  # rm -f ${virtualbox_extenpack_file}*
  # check_status
#############################################
  printf "${b}for libreoffice... ${n}"
  sudo apt-get install -q -y libreoffice >> $logd
  check_status
  #############################################
  printf "${b}for wireshark... ${n}"
  sudo add-apt-repository -y ppa:wireshark-dev/stable > /dev/null && sudo apt-get update > /dev/null && \
  sudo apt-get install -q -y wireshark
  check_status
  printf "${b}for wine likes programs... ${n}"
  # For Ubuntu 18.04:
    # install wine: https://wiki.winehq.org/Ubuntu
    # Error:
    #The following packages have unmet dependencies:
    # winehq-stable : Depends: wine-stable (= 5.0.0~bionic)
    #E: Unable to correct problems, you have held broken packages.
  # https://wiki.winehq.org/Ubuntu
  sudo dpkg --add-architecture i386 && \
  wget -q -O - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add - && \
  sudo sh -c 'echo "deb https://dl.winehq.org/wine-builds/ubuntu/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/wine.list' && \
  sudo apt-get update > /dev/null && \
  # if Ubuntu 20.04 Error: Could not configure 'libc6:i386' then sudo apt upgrade
  sudo apt-get install -q -y winehq-stable playonlinux >> $logd

:<<-EOF
  # playonlinux
  # 2020-07-14: There isn't playonlinux ppa for Ubuntu 20.04
  wget -q -O - "http://deb.playonlinux.com/public.gpg" | sudo apt-key add - && \
  sudo wget -q http://deb.playonlinux.com/playonlinux_`lsb_release -sc`.list -O /etc/apt/sources.list.d/playonlinux.list && \
  sudo apt-get update > /dev/null && \
  sudo apt-get install -q -y playonlinux winetricks >> $logd 
  check_status
EOF
  #############################################
  printf "${b}for images... ${n}"
  sudo apt-get install -q -y gimp pinta gthumb >> $logd && \
  # https://github.com/cas--/PasteImg
  sudo cp -f $dir_data/pasteimg $bin && sudo chmod +x $bin/pasteimg
  check_status
  #############################################
  printf "${b}for media... ${n}"
  sudo apt-get install -q -y vlc smplayer audacity >> $logd
  # for 14.04
  #sudo apt-get install -q -y gnome-mplayer >> $logd
  check_status
  #############################################
  printf "${b}for BasKet... ${n}"
  #for 14.04
  #sudo apt-get install -q -y unetbootin k3b >> $logd
  sudo apt-get install -q -y basket >> $logd
  check_status
  printf "${b}  BasKet fixing... ${n}"
sudo bash -c 'cat <<-EOFBASKET > /usr/bin/basket_fixed.sh
#!/bin/bash
unset SESSION_MANAGER
basket
EOFBASKET
' && \
  sudo chmod +x /usr/bin/basket_fixed.sh && \
  sudo sed -i 's/Exec=basket.*$/Exec=\/usr\/bin\/basket_fixed.sh/' /usr/share/applications/basket.desktop
  check_status
  #############################################
  printf "${b}for others... ${n}"
  #for 14.04
  #sudo apt-get install -q -y unetbootin k3b >> $logd
  sudo apt-get install -q -y baobab >> $logd
  check_status
  #############################################
  printf "${b}for smb(Samba)... ${n}"
  sudo apt-get install -q -y smbclient cifs-utils >> $logd
  check_status
  sudo sed -i "/\[global\]/a \ \ \ client min protocol = NT1" /etc/samba/smb.conf
  
  # libreoffice doesn't support muilti-spellcheching
  #printf "${b}plugins for LibreOffice... ${n}"
  #export libreoffice_languagetools='https://www.languagetool.org/download/LanguageTool-3.0.oxt'
  #dir_download=/tmp/libreoffice_plugins && \
  #  mkdir $dir_download && \
  #  wget -q $libreoffice_languagetools http://extensions.libreoffice.org/extension-center/russian-spellcheck-dictionary.-based-on-works-of-aot-group/pscreleasefolder.2011-09-06.6209385965/0.4.0/dict_ru_ru-aot-0-4-0.oxt -P $dir_download && \
  #  rm -Rf $dir_download
  #check_status
  #
  #Youtube Downloader
  # https://github.com/ytdl-org/youtube-dl
  # sudo -H pip install --upgrade youtube-dl
  #

  #############################################
  printf "${b}simple screen recorder...${n}"
  sudo add-apt-repository -y ppa:maarten-baert/simplescreenrecorder > /dev/null && sudo apt-get update > /dev/null && \
  sudo apt-get install -q -y simplescreenrecorder >> $logd
  check_status

  #############################################
  echo
  printf "${b}Installing utils for programming... ${n}"
  sudo apt-get install -q -y meld kate >> $logd
  check_status
fi

#############################################
if [[ "$mode" = "server" ]]; then
  printf "${b}nginx... ${n}"
  sudo apt-get install -q -y nginx >> $logd && \
    nginx -v
  check_status
  
:<<-EOF
  printf "The latest ${b}nginx... ${n}"
  sudo sh -c 'echo "deb https://nginx.org/packages/ubuntu/ `lsb_release -sc` main" > /etc/apt/sources.list.d/nginx.list' && \
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C && \
    sudo apt-get update && \
    sudo apt-get install -q -y nginx >> $logd && \
    nginx -v
  check_status
  # "
  # If a W: GPG error: https://nginx.org/packages/ubuntu focal InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY $key
  ## Replace $key with the corresponding $key from your GPG error.
    # sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $key
    # sudo apt update
EOF
fi

#############################################
printf "${b}for tlp (power saving utils)...${n}"
sudo apt-get install -q -y smartmontools ethtool linux-tools-`uname -r` >> $logd
check_status
#sudo add-apt-repository -y ppa:linrunner/tlp > /dev/null && sudo apt-get update > /dev/null && \
#sudo apt-get install -q -y tlp tlp-rdw smartmontools ethtool linux-tools-`uname -r` >> $logd
#############################################
:<<-EOF
printf "${b}VNC (Remote Desktop)...${n}"
# if you need VNC server (x11vnc) see manual in the Basket
sudo add-apt-repository -y ppa:remmina-ppa-team/remmina-next > /dev/null && sudo apt-get update > /dev/null && \
sudo apt-get install -q -y remmina remmina-plugin-rdp remmina-plugin-secret >> $logd
check_status
EOF
:<<-EOF
# light-locker switch from DISPLAY=:0 to :1, what case problem with VNC logging
printf "${b}  Replacing light-locker for gnome-screensaver...${n}"
sudo apt-get purge -q -y light-locker >> $logd && \
sudo apt-get install -q -y gnome-screensaver >> $logd && \
#sudo killall light-locker
check_status
EOF

#############################################
printf "${b}OpenVPN...${n}"
sudo apt-get install -q -y openvpn network-manager-openvpn >> $logd
check_status
#############################################
echo
printf "${b}Forward copy/paste-buffer via ssh... ${n}"
sudo apt-get install -q -y xclip >> $logd && \
  echo "ForwardX11 yes" >> ~/.ssh/config
check_status

if [[ "$mode" = "desktop" ]]; then
    printf "${b}\tInstalling utils for C++ programming... ${n}"
    # for 14.04
    #sudo add-apt-repository -y ppa:george-edison55/cmake-3.x > /dev/null && \
    # sudo apt-get update > /dev/null && \
    sudo apt-get install -q -y g++ valgrind doxygen cmake gdb clang >> $logd
    check_status
fi
:<<-EOF
printf "${b}\tInstalling utils for RDBMS programming... ${n}"
wget -q -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && \
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -sc`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
check_status
sudo apt-get update > /dev/null && \
sudo apt-get install -q -y postgresql-9.6 postgresql-server-dev-9.6 >> $logd && \
  sudo -u postgres psql -c "create role $USER with superuser createdb createrole inherit login replication bypassrls"
check_status
EOF
:<<-EOF
# Ubuntu 20.04: Query Tool crashed with error:
# gdk_drawing_context_get_cairo_context: assertion 'GDK_IS_DRAWING_CONTEXT (context)' failed. Segmentation fault
printf "${b}\t\tInstalling & setting pgadmin3... ${n}"
sudo apt-get install -q -y pgadmin3 >> $logd && \
  cp $dir_data/.pgadmin3 ~/ && sed -i "s/snaiffer/$USER/g" ~/.pgadmin3
check_status
EOF
printf "${b}\t\tInstalling sqldump_search... ${n}"
git clone -q https://github.com/snaiffer/sqldump_search.git ~/git/sqldump_search && \
cd ~/git/sqldump_search && git remote set-url origin git@github.com:snaiffer/sqldump_search.git && cd $OLDPWD && \
sudo ln -s ~/git/sqldump_search/sqldump_search.py /usr/bin/sqldump_search
check_status

# Valentina-DB (VStudio)
# http://valentina-db.com/download/
# Serial code:
#   Alexander
#   Danilov
#   a.danilov@runabank.ru
#   VS-L-DWF2NA2H61XL9EA8-61UMWAT575Q3YEKT-R3W9F4ECM74A82EC-LYG9D2NMKU7T29J4

:<<-EOF
Oracle SQLDeveloper
use: https://dev.to/ishakantony/how-to-install-oracle-sql-developer-on-ubuntu-20-04-3jpd
but install sqldeveloper from rpm with help of "alien"
sudo cp /opt/sqldeveloper/sqldeveloper.desktop /usr/share/applications
EOF

printf "${b}\tInstalling Person Action Simulator... ${n}"
sudo apt-get install -q -y xdotool  >> $logd
sudo cp $dir_data/action_simulator/action_simulator.sh /opt/
cp $dir_data/action_simulator/action_simulator.desktop ~/Desktop
check_status

printf "${b}\tInstalling utils for Python programming... ${n}"
sudo apt-get install -q -y python3 ipython3 >> $logd
check_status
<<-EOF
PyCharm
sudo snap install [pycharm-professional|pycharm-community] --classic
EOF
<<-EOF
printf "${b}\t\tselenium... ${n}"
sudo apt install python3-pip && \
pip3 install selenium && \
pip3 install pyvirtualdisplay && \
sudo apt-get install xvfb

Download ChromeDriver:
https://sites.google.com/a/chromium.org/chromedriver/home

sudo mv chromedriver /usr/bin/chromedriver && \
sudo chown root:root /usr/bin/chromedriver && \
sudo chmod +x /usr/bin/chromedriver
EOF

<<-EOF
echo
printf "${b}Set keyboardlayout switcher by Caps key... ${n}"
sudo sed -i "s/XKBOPTIONS=\"/XKBOPTIONS=\"grp:caps_toggle\,/" /etc/default/keyboard
## work on HP Pavilion laptop with Lubuntu
#sudo cp -f $dir_data/keyboardlayout_switcher.desktop /etc/xdg/autostart/
check_status
EOF

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
cd ~/git/syncfrom/ && git remote set-url origin git@github.com:snaiffer/syncfrom.git && cd $OLDPWD && \
check_status

printf "${b}Setting bash enviroment... ${n}"
git clone -q https://github.com/snaiffer/bash_env.git ~/.bash_env && \
cd ~/.bash_env && git remote set-url origin git@github.com:snaiffer/.bash_env.git && cd $OLDPWD && \
~/.bash_env/install.sh > /dev/null
check_status

printf "${b}Setting vim... ${n}"


sudo apt-get install -q -y vim clang libclang-dev \
  $(if (( $os_release_major < 22 )); then echo ctags else echo exuberant-ctags fi) \
  >> $logd && \
rm -Rf ~/.vim ~/.vimrc && \
git clone -q https://github.com/snaiffer/vim.git ~/.vim && \
cd ~/.vim && git remote set-url origin git@github.com:snaiffer/vim.git && cd $OLDPWD && \
ln -s ~/.vim/vimrc ~/.vimrc && \
vim -c "BundleInstall" -c 'qa!'
#~/.vim/bundle/youcompleteme
check_status

printf "${b}Turn off apport... ${n}"
sudo sed -i "s/enabled=1/enabled=0/" /etc/default/apport
check_status

:<<-EOF
# for Lenovo Yoga only
echo
printf "${b}Fixing bug with Lenovo IdeaPad Yoga 13... ${n}"
# /var/log/syslog: atkbd serio0: Unknown key released (translated set 2, code 0xbe on isa0060/serio0)
# kernel: [57478.570447] atkbd serio0: Use 'setkeycodes e03e <keycode>' to make it known
sudo dmidecode |grep 'Lenovo IdeaPad Yoga 13' && sudo setkeycodes e03e 255
check_status
EOF

:<<-EOF2
# Set up mouse scroll speed
# https://dev.to/bbavouzet/ubuntu-20-04-mouse-scroll-wheel-speed-536o
sudo apt install imwheel
# set up via GUI
bash <(curl -s http://www.nicknorton.net/mousewheel.sh)
# Manualy add "imwheel" to the list of startup applications
EOF2

echo
printf "${b}Installing sysbench... ${n}"
sudo apt-get install -q -y sysbench >> $logd
check_status
echo "${b}Start 'sysbench --test=cpu run':${n}"
echo "${b}================================================${n}"
sysbench --test=cpu --threads=`nproc` run
echo "${b}================================================${n}"

:<<-EOF
echo
echo "Foxit Reader PDF (very fast and pretty)"
echo "You can download and install it manually. Go to:"
echo "https://www.foxitsoftware.com/downloads/"
echo "<Enter>" && read

echo
#sudo apt-get install -q -y winbind >> $logd 
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
EOF


if [[ "$mode" = "server" ]]; then
  echo -e "Change lid and key actions"
  sudo sed -i "/HandleLidSwitch/d" /etc/systemd/logind.conf && \
  sudo sh -c 'echo "HandleLidSwitch=ignore" >> /etc/systemd/logind.conf' && \
  sudo sed -i "/HandleSuspendKey/d" /etc/systemd/logind.conf && \
  sudo sh -c 'echo "HandleSuspendKey=ignore" >> /etc/systemd/logind.conf' && \
  sudo sed -i "/HandleLidSwitchDocked/d" /etc/systemd/logind.conf && \
  sudo sh -c 'echo "HandleLidSwitchDocked=ignore" >> /etc/systemd/logind.conf'
  check_status

  echo -e "Ubuntu desktop to Ubuntu server"
  sudo apt-get install -q -y tasksel >> $logd
  sudo tasksel remove ubuntu-desktop >> $logd
  sudo tasksel install server >> $logd
  sudo apt-get purge -q -y lightdm >> $logd

  Edit /etc/default/grub:
  GRUB_CMDLINE_LINUX_DEFAULT="text"

  sudo update-grub
  sudo systemctl set-default multi-user.target
fi

echo
printf "${b}Removing no longer required packages... ${n}"
sudo apt-get autoremove -q -y >> $logd
check_status

echo
reboot_request
#printf "${b}Relogin... ${n}"
#sudo service lightdm restart