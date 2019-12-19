# autodeploy_os

## Requements:
- Debian family
- LXDE, XFCE(???) desktop managers
- home dir has to be "/home/<user_name>"

## It has been tested on:
- Xubuntu 14.04.3 amd64

## Update config. files of autodeploy_os
export dir_data="$dir_script/data"
exportlist="xfce4 compiz-1 Mousepad Thunar terminator"

for cur in $exportlist; do
  printf "${b}\t of $cur... ${n}"
  rm -Rf $dir_data/config/$cur && cp -Rf ~/.config/$cur $dir_data/config/ && \
    find $dir_data/config/$cur -type f -print0 | xargs -0 sed "s/$USER/snaiffer/g"
  check_status
done

Check changes with difftool:
git difftool -d

## Plans:
- Check list for modules installation of autodeploy
- Save sysbench (benchmark) info to file or server
- There may be some interesting info: http://howtoubuntu.org/things-to-do-after-installing-ubuntu-14-04-trusty-tahr
- Command for updating enviroment settings in autodeploy_os according to the current env. settings

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
