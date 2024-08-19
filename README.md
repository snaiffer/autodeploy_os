# autodeploy_os

## Requements:
- Debian family
- home dir has to be "/home/<user_name>"

## It has been tested on:
- Xubuntu 14.04.3
- Xubuntu 18.04.4
- Xubuntu 20.04.0
- Xubuntu 20.04.4
- Xubuntu 22.04.1
- Ubuntu Server 22.04.2
- Kubuntu 24.04

## Install
mkdir -p ~/git && cd ~/git && git clone https://github.com/snaiffer/autodeploy_os && cd autodeploy_os
./autodeploy_os_<distributive>.sh 2>&1 | tee ./log_`date +%m%d_%H%M`


# Below information is for Xubuntu only

## Update config. files of autodeploy_os
Go to root dir of autodeploy_os

export dir_data="./data"
exportlist="xfce4 compiz-1 Mousepad Thunar terminator"

for cur in $exportlist; do
  printf "${b}\t of $cur... ${n}"
  rm -Rf $dir_data/config/$cur && cp -Rf ~/.config/$cur $dir_data/config/ && \
    find $dir_data/config/$cur -type f -print0 | xargs -0 sed "s/$USER/snaiffer/g"
done

Check changes with difftool:
git difftool -d

There may be some interesting info: http://howtoubuntu.org/things-to-do-after-installing-ubuntu-14-04-trusty-tahr

## Bugs:
In case of problems with desktop or background image:

```sh
rm ~/.config/xfce4/desktop/*
# Change to
# <property name="last-image" type="string" value="/usr/share/xfce4/backdrops/solitude.jpg"/>
vim ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
rm ~/.cache/sessions/*
sudo service lightdm restart
```

## Others:
- To turn on microphone: PulseAudio Configuration/Analog Stereo Duplex
