machinectl bind --mkdir $MACHINE /run/user/1000/wayland-1 /tmp/wayland.sock
machinectl bind --mkdir $MACHINE /run/user/1000/pulse/native /tmp/pulse-native
machinectl bind --mkdir $MACHINE /run/user/1000/pipewire-0 /tmp/pipewire-0
machinectl bind --mkdir $MACHINE /tmp/.X11-unix /tmp/.X11-unix
