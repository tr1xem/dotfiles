# Cava gradient support for Tmux
alias cavax 'TERM=st-256color cava'
alias init="sudo mkinitcpio -P linux-lts"
alias clean="paru -Scc && sudo pacman -Scc"
alias update="paru"
alias downloadmp3="yt-dlp --extract-audio --audio-format mp3 --audio-quality 0"
alias downloadmp4='yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4'
#other
alias tree='eza -a --tree --color always --icons --group-directories-first'
alias treell='eza -a -l -b --tree --color always --icons --group-directories-first'
alias ls='eza -a --color always --icons --group-directories-first'
alias ll='eza -a -l -b --color always --icons --group-directories-first'
alias cat="bat"
# alias vim="nvim"
alias clock="tty-clock -s -c -B -t -x -b"
alias hows-my-gpu='echo "NVIDIA Dedicated Graphics" && lspci -nnk | grep -i "NVIDIA" -A 2 | grep "Kernel driver in use" || echo "No NVIDIA GPU detected"; echo "Intel Corporation Raptor Lake-S UHD Graphics" && lspci -nnk | grep -i "Intel.*Graphics" -A 3 | grep "Kernel driver in use" || echo "No Intel GPU detected"; echo "Enable and disable the dedicated NVIDIA GPU with nvidia-enable and nvidia-disable"'
alias nvidia-enable='sudo rmmod vfio_pci vfio_pci_core vfio_iommu_type1 && echo "VFIO drivers removed" && sudo modprobe -i nvidia_modeset nvidia_uvm nvidia && echo "NVIDIA drivers added" && echo "COMPLETED!"'
alias nvidia-disable='sudo rmmod nvidia_modeset nvidia_uvm nvidia && echo "NVIDIA drivers removed" && sudo modprobe -i vfio_pci vfio_pci_core vfio_iommu_type1 && echo "VFIO drivers added" && echo "COMPLETED!"'
alias pamcan=pacman
alias ollama="prime-run ollama"
alias checknvidia="cat /proc/driver/nvidia/gpus/0000:01:00.0/power"
alias dectohex="printf '0x%x\n' $1"
alias hextodec="printf '%d\n' $1"
alias mike="mpv https://www.youtube.com/playlist?list=PLvv0ScY6vfd8j-tlhYVPYgiIyXduu6m-L"
alias snapshotclean="sudo zfs list -H -o name -t snapshot | grep '@zrepl_' | xargs -n1 sudo zfs destroy"

function parusweep
    set orphans (paru -Qdtq)
    if test -z "$orphans"
        echo "✅ No orphaned packages found."
    else
        echo "🗑  Orphaned packages:"
        printf "%s\n" $orphans
        paru -Rns $orphans
    end
end
function fish_user_key_bindings
    bind \ct __open_todo
end

function __open_todo
    nvim +"cd $HOME/dotfiles/personal/personal/orgfiles" \
        "$HOME/dotfiles/personal/personal/orgfiles/refile.org"
end

function run_bash_script
    bash ~/.local/bin/tmux-sessionizer
end

bind \cf run_bash_script


function ilspyx
    if test (count $argv) -lt 1
        echo "Usage: ilspyx <assembly.dll> [extra ilspycmd args...]"
        return 1
    end

    set asm $argv[1]
    set base (basename $asm .dll)

    mkdir -p $base
    ilspycmd -p -o $base $argv
end

function pixelmpv
    set url $argv[1]
    set id (string match -r '[A-Za-z0-9]{8,}$' $url)
    curl -s "https://pixeldrain.net/api/list/$id" \
        | jq -r '"#EXTM3U", (.files[]? | select(.mime_type | startswith("video/") or startswith("audio/")) | "#EXTINF:-1," + .name, "https://pixeldrain.net/api/file/" + .id)' \
        | mpv --playlist=-
end
alias rm='rm -i'
alias orgmode='nvim -c "cd ~/personal/orgfiles"  -c "Oil"'
alias yay='paru'
alias flutter='fvm flutter'
alias cpu 'watch -n1 '\''grep "cpu MHz" /proc/cpuinfo | awk "{ printf \"CPU %-2d: %4.0f MHz\n\", NR-1, \$4 }"'\'''
