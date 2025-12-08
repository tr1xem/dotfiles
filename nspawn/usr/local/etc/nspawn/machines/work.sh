source /usr/local/etc/nspawn/configpacks/desktop.sh
source /usr/local/etc/nspawn/configs/limits.sh
machinectl bind --mkdir $MACHINE /home/saumya/work
machinectl bind --mkdir $MACHINE /home/saumya/.cache/cppman/
