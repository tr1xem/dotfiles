# ## Auto start Hyprland on tty1
# if not set -q DISPLAY; and test "$XDG_VTNR" = 1
#     if uwsm check may-start
#         exec uwsm start hyprland.desktop 2> ~/.cache/hyprland.log
#     end
# end
#
#    mkdir -p ~/.cache
#    exec Hyprland 2> ~/.cache/hyprland.log
#
#    #exec Hyprland
