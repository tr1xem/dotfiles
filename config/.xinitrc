#!/bin/sh
xhost +local:
exec fish -c "rfkill unblock bluetooth; dbus-run-session xmonad"
