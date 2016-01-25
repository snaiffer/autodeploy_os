# autodeploy_os

## Requements:
- Debian family
- LXDE, XFCE(???) desktop managers

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
vim ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
rm ~/.cache/sessions/
sudo service lightdm restart
```
