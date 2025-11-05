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

fish_add_path /home/saumya/.opencode/bin
fish_add_path /home/saumya/.pixi/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.local/bin/bin
fish_add_path /home/saumya/.local/bin
fish_add_path /home/saumya/.spicetify
fish_add_path /home/saumya/.local/bin/statusbar

source ~/.config/fish/aliases.fish
source ~/.config/fish/ffmpeg.fish
source ~/.config/fish/env.fish
source ~/.config/fish/auto-Hypr.fish
if test -f ~/.config/fish/keys.fish
    source ~/.config/fish/keys.fish
end
