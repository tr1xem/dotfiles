machinectl bind --mkdir $MACHINE /tmp/.X11-unix
machinectl bind --mkdir --read-only $MACHINE /usr/local/etc/nspawn/profile.d/xorg.sh /etc/profile.d/nspawn_xorg.sh
machinectl bind --mkdir $MACHINE /run/user/1000/pipewire-0 /tmp/pipewire-0
machinectl bind --mkdir $MACHINE /run/user/1000/pulse/native /tmp/pulse-native
mkdir /tmp/nspawn
chmod +rwx /tmp/nspawn
machinectl bind --mkdir --read-only $MACHINE /tmp/nspawn
