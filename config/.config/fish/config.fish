if status is-interactive
    if test (tty) != "/dev/tty1" # Replace tty1 with the TTY you want to exclude
        pokemon-colorscripts-go --no-title
    end
end
set -U fish_greeting
set -U fifc_fd_opts --hidden
set -U fifc_bat_opts --style=numbers
set -Ux fifc_editor nvim
# starship init fish | source
zoxide init fish --cmd cd | source
set -x COLORTERM truecolor
set -x MANPAGER "nvim +Man!"

fish_add_path $HOME/.opencode/bin
fish_add_path $HOME/.pixi/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.spicetify
fish_add_path $HOME/go/bin
fish_add_path $HOME/.local/bin/statusbar
fish_add_path $HOME/.ghcup/bin
fish_add_path $HOME/flutter/bin
fish_add_path /run/media/saumya/tank/public/Android/SDK/platform-tools

source ~/.config/fish/aliases.fish
source ~/.config/fish/env.fish
if test -f ~/.config/fish/keys.fish
    source ~/.config/fish/keys.fish
end

if test -d $HOME/perl5
    eval "$(perl -I $HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"
end


set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin $PATH /home/saumya/.ghcup/bin # ghcup-env