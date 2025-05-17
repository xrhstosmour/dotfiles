# Add `Homebrew`'s binary directory to the `PATH` environment variable.
set kernel_name (uname -s)
if test "$kernel_name" = "Darwin"
  fish_add_path "/opt/homebrew/bin/"
end

# Disable `Homebrew` environment update hints.
set -gx HOMEBREW_NO_ENV_HINTS 1

# Enable `Starship` as `Fish` prompt.
starship init fish | source

# Enable `Zoxide` at `Fish` shell.
zoxide init fish | source

# Enable and configure `Atuin` at `Fish` shell.
set -gx ATUIN_NOBIND "true"
atuin init fish | source
bind \ch _atuin_search
bind -M insert \ch _atuin_search

# Disable welcome message.
set -U fish_greeting

# Source needed `Fish` constants.
source $HOME/.config/fish/constants/colors.fish

# Source needed `Fish` functions.
source $HOME/.config/fish/functions/files.fish
source $HOME/.config/fish/functions/git.fish
source $HOME/.config/fish/functions/logs.fish

# Source `Linux` specific `Fish` functions.
if test "$kernel_name" = "Linux"
  source $HOME/.config/fish/functions/copy.fish
  source $HOME/.config/fish/functions/trashy.fish
end
