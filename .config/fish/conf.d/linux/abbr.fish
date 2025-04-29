# System abbreviations.
abbr um "rate-mirrors --disable-comments-in-file --save mirrors.txt arch && cat mirrors.txt | head -n 5 | sudo tee /etc/pacman.d/mirrorlist && sudo rm mirrors.txt"
abbr us "sudo pacman-db-upgrade && sudo pacman -Sy && sudo pacman -S --noconfirm --needed archlinux-keyring && paru -Su --noconfirm"
abbr pi "paru -S --noconfirm --needed"
abbr pr "paru -Rns --noconfirm"
abbr ip "ip -br a | grep UP | awk '{print \"Interface: \" \$1 \"\nIPv4: \" \$3}'"
abbr po "sudo systemctl poweroff"
abbr zzz "sudo systemctl suspend"

# Terminal tools abbreviations.
abbr t "trash"
abbr tl "trash list"
abbr te "trash_empty"
abbr tr "trash_restore"
abbr tea "trash empty --all"

# Services abbreviations.
abbr sc "sudo systemctl"
abbr scsts "sudo systemctl status"
abbr sci "sudo systemctl info"
abbr scstr "sudo systemctl start"
abbr sce "sudo systemctl enable"
abbr scstp "sudo systemctl stop"
abbr scd "sudo systemctl disable"
abbr scrr "sudo systemctl reload-or-restart"

# `Docker` abbreviations.
abbr dc "docker-compose"
abbr dcu "docker-compose up --build -d"
abbr dcd "docker-compose down"
abbr de "docker-compose exec --it /bin/bash"
abbr dcp "docker-compose down -v --remove-orphans && echo y | docker system prune -a --volumes"
