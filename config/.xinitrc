#!/bin/sh
xhost +local:
exec fish -c "rfkill unblock bluetooth;xmonad"
