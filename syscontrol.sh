#!/bin/sh

ACTION=`zenity --width=90 --height=100 --list --radiolist --text="" --title="Logout" --column "" --column "" --hide-header TRUE Shutdown FALSE "Reboot"`

if [ -n "${ACTION}" ];then
  case $ACTION in
  Shutdown)
    gksudo poweroff
    ;;
  Reboot)
    gksudo reboot
    ;;
  esac
fi
