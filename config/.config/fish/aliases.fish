# Cava gradient support for Tmux
alias cavax 'TERM=st-256color cava'
alias mirrors="sudo reflector -c ID,SG -l 7 -f 7 -p https --sort rate --save /etc/pacman.d/mirrorlist"
alias init="sudo mkinitcpio -P linux-lts"
alias grub-update="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias clean="paru -Scc && sudo pacman -Scc"
alias autoremove="paru -Qdtq | paru -Rs"
alias update="paru -Syu"
alias music="foot -e cmus"
alias youtube="ytfzf -f -t --notify-playing --type=all "
alias download="ytfzf -d -f"
alias ytmusic="ytfzf --notify-playing --audio-only "
alias downloadmp3="yt-dlp --extract-audio --audio-format mp3 --audio-quality 0"
#other
alias tree='eza -a --tree --color always --icons --group-directories-first'
alias treell='eza -a -l -b --tree --color always --icons --group-directories-first'
alias ls='eza -a --color always --icons --group-directories-first'
alias ll='eza -a -l -b --color always --icons --group-directories-first'
alias cat="bat"
alias mem="echo tami | sudo -S ps_mem"
alias hdd="echo tami | sudo -S hdsentinel"
alias recordaudio="wf-recorder --audio=alsa_output.pci-0000_00_1b.0.analog-stereo.monitor --file=wf-recorder-audio.mp4"
alias recordvideo="wf-recorder --file=wf-recorder-no-audio.mp4"
# alias vim="nvim"
# alias btop="btop --utf-force"
alias clock="tty-clock -s -c -B -t -x -b"
# alias tmux="tmux -u"
alias hows-my-gpu='echo "NVIDIA Dedicated Graphics" && lspci -nnk | grep -i "NVIDIA" -A 2 | grep "Kernel driver in use" || echo "No NVIDIA GPU detected"; echo "Intel Corporation Raptor Lake-S UHD Graphics" && lspci -nnk | grep -i "Intel.*Graphics" -A 3 | grep "Kernel driver in use" || echo "No Intel GPU detected"; echo "Enable and disable the dedicated NVIDIA GPU with nvidia-enable and nvidia-disable"'
alias nvidia-enable='sudo virsh nodedev-reattach pci_0000_01_00_0 && echo "GPU reattached (now host ready)" && sudo rmmod vfio_pci vfio_pci_core vfio_iommu_type1 && echo "VFIO drivers removed" && sudo modprobe -i nvidia_modeset nvidia_uvm nvidia && echo "NVIDIA drivers added" && echo "COMPLETED!"'
alias nvidia-disable='sudo rmmod nvidia_modeset nvidia_uvm nvidia && echo "NVIDIA drivers removed" && sudo modprobe -i vfio_pci vfio_pci_core vfio_iommu_type1 && echo "VFIO drivers added" && sudo virsh nodedev-detach pci_0000_01_00_0 && echo "GPU detached (now vfio ready)" && echo "COMPLETED!"'
alias scxgame='dbus-send --system --print-reply --dest=org.scx.Loader /org/scx/Loader org.scx.Loader.SwitchScheduler string:scx_lavd uint32:1'
alias scxpower=' dbus-send --system --print-reply --dest=org.scx.Loader /org/scx/Loader org.scx.Loader.SwitchScheduler string:scx_lavd uint32:2'
alias pamcan=pacman
alias ollama="prime-run ollama"
alias server="ssh -p 22022 root@209.74.86.34"
alias study="sh /run/media/saumya/Nexus/Games/study.sh"
alias checknvidia="cat /proc/driver/nvidia/gpus/0000:01:00.0/power"
alias dectohex="printf '0x%x\n' $1"
alias hextodec="printf '%d\n' $1"
alias vencordinstall='sh -c "$(curl -sS https://vencord.dev/install.sh)"'

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
    cd ~/dotfiles
    nvim todo.md
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

    # create output folder if missing
    mkdir -p $base

    # run ilspycmd
    ilspycmd -p -o $base $argv
end

function pixelmpv
    set url $argv[1]
    set id (string match -r '[A-Za-z0-9]{8,}$' $url)
    curl -s "https://pixeldrain.net/api/list/$id" \
        | jq -r '"#EXTM3U", (.files[]? | select(.mime_type | startswith("video/") or startswith("audio/")) | "#EXTINF:-1," + .name, "https://pixeldrain.net/api/file/" + .id)' \
        | mpv --playlist=-
end


