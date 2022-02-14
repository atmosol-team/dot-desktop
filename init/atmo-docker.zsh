# Aliases
alias d=dock

# set PATH to include atmosol executables
if [ -d "$HOME/.atmo-dock/bin" ] ; then
    PATH="$HOME/.atmo-dock/bin:$PATH"
fi

# Redirect from WSL default directory since linux fs is faster
pwd | grep -E "^/mnt/./Users/[^/]+/?$" &>/dev/null && cd
