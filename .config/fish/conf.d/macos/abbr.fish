# System abbreviations.
abbr us "brew update && brew upgrade && brew upgrade --cask && mas upgrade"
abbr pi "brew install"
abbr pr "brew uninstall"
abbr ip "printf 'IPv4 (en0): %s\n' $(ipconfig getifaddr en0)"
abbr ka "sudo killall coreaudiod bluetoothd bluetoothaudiod"
abbr po "sudo shutdown -h now"
abbr zzz "sudo pmset sleepnow"

# Services abbreviations.
abbr sc "sudo launchctl"
abbr scsts "sudo launchctl list"
abbr sci "sudo launchctl print"
abbr scstr "sudo launchctl load"
abbr sce "sudo launchctl load -w"
abbr scstp "sudo launchctl unload"
abbr scd "sudo launchctl unload -w"
abbr scrr "sudo launchctl kickstart -k"

# `Docker` abbreviations.
abbr dc "docker compose"
abbr dcu "docker compose up --build -d"
abbr dcd "docker compose down"
abbr de "docker compose exec --it /bin/bash"
abbr dcp "docker compose down -v --remove-orphans && echo y | docker system prune -a --volumes"
