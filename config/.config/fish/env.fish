set -xg TERMINAL kitty
set -xg EDITOR nvim
xdg-user-dirs-update

set -xg XDG_DESKTOP_DIR (xdg-user-dir DESKTOP)
set -xg XDG_DOWNLOAD_DIR (xdg-user-dir DOWNLOAD)
set -xg XDG_TEMPLATES_DIR (xdg-user-dir TEMPLATES)
set -xg XDG_PUBLICSHARE_DIR (xdg-user-dir PUBLICSHARE)
set -xg XDG_DOCUMENTS_DIR (xdg-user-dir DOCUMENTS)
set -xg XDG_MUSIC_DIR (xdg-user-dir MUSIC)
set -xg XDG_PICTURES_DIR (xdg-user-dir PICTURES)
set -xg XDG_VIDEOS_DIR (xdg-user-dir VIDEOS)
set -Ux OLLAMA_MODELS /run/media/saumya/Nexus/ollama/
# set -gx CCACHE_CPP2 yes
set -xg CFLAGS "-fdiagnostics-color=always -std=c23"
set -xg CXXFLAGS "-fdiagnostics-color=always -std=c++26"
set -gx CC clang
set -gx CXX clang++
set -gx TERM xterm-256color
set -gx DBUS_SESSION_BUS_ADDRESS "unix:path=/run/user/1000/bus"
set -gx EDITOR "nvim"
set -gx CHROME_EXECUTABLE /usr/bin/thorium-browser
set -gx VISUAL "$EDITOR"

set -xg QT_QPA_PLATFORMTHEME qt6ct
set -Ux TERM xterm-kitty
set -g fish_term24bit 1
set -Ux LANG en_IN.UTF-8
set -Ux LC_ALL en_IN.UTF-8

if test -e ~/.config/fish/api.fish
  source ~/.config/fish/api.fish
end

set -x OPENAI_BASE_URL http://0.0.0.0:4141
# set -x OPENAI_API_KEY "n/a"


# set -xg WAYLAND_DISPLAY /tmp/wayland.sock
# set -xg PIPEWIRE_REMOTE /tmp/pipewire-0
# set -xg PULSE_SERVER unix:/tmp/pulse-native
# set -xg DISPLAY :0         # match the XWayland display
# set -xg XAUTHORITY /run/user/1000/.Xauthority  # optional, if X server requires auth

export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
fish_add_path $ANDROID_HOME/platform-tools
fish_add_path $ANDROID_HOME/cmdline-tools/latest/bin
fish_add_path $ANDROID_HOME/emulator
