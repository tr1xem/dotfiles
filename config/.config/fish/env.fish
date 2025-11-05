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
# set -xg CXX clang++
set -Ux OLLAMA_MODELS /run/media/saumya/Nexus/ollama/
# set -xg CMAKE_GENERATOR Ninja
set -xg CFLAGS "-fdiagnostics-color=always"
set -gx CXXFLAGS "-std=c++23"
set -gx CFLAGS "-std=c23"
set -xg CXXFLAGS "-fdiagnostics-color=always"
set -gx EDITOR "nvim"  # Replace "nano" with your desired editor (e.g., vim, nvim, etc.)
set -gx VISUAL "$EDITOR"
set -xg CXX "ccache clang++"
set -xg CC "ccache clang"
# set -xg CC "ccache gcc"
# set -xg CXX "ccache g++"

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

