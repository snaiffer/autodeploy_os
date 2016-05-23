# autodeploy_os

## Requements:
- Debian family
- LXDE, XFCE(???) desktop managers
- home dir has to be "/home/<user_name>"

## It has been tested on:
- Xubuntu 14.04.3 amd64

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
