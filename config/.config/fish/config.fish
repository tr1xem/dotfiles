if status is-interactive
    if test (tty) != "/dev/tty1" # Replace tty1 with the TTY you want to exclude
        pokemon-colorscripts-go --no-title
    end

    # Commands to run in interactive sessions can go here
end

# ~/.config/fish/config.fish


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

source ~/.config/fish/aliases.fish
source ~/.config/fish/env.fish
if test -f ~/.config/fish/keys.fish
    source ~/.config/fish/keys.fish
end

# Start X automatically on tty1
if status is-login
    if test (tty) = "/dev/tty1"
        if not set -q DISPLAY
            exec startx
        end
    end
end
# if test $HOME/perl5
#     eval "$(perl -I $HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"
# end
