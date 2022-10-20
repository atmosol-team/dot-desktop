#!/usr/bin/env bash

# Main list of packages for desktop. OS-agnostic.
packages=(
    thomshouse/git
    atmosol-team/vscode
    atmosol-team/zsh
    thomshouse-ellipsis/docker
);

# List of apt packages to install on any apt-based system
apt_packages=(
    git-lfs
    imagemagick
    keychain
    php
    php-cli
    php-fpm
    php-json
    php-common
    php-mysql
    php-zip
    php-gd
    php-mbstring
    php-curl
    php-xml
    php-pear
    php-bcmath
    zip
    unzip
);

# List of homebrew formulae to install on MacOS-based systems
brew_packages=(
    imagemagick
    keychain
    php@7.4
);
cask_packages=(
    firefox
    googlechrome
    iterm2
    microsoft-office
    slack
    tunnelblick
);

# List of choco packages to install on Windows systems
choco_packages=(
    firefox
    googlechrome
    microsoft-office-deployment
    microsoft-windows-terminal
    slack
    # libreoffice-fresh
    # openvpn-connect
    # ringcentral-classic
);

# Set of platform-specific prerequisites to support each platform
linux_prereqs=()
macos_prereqs=()
wsl_prereqs=(
    thomshouse-ellipsis/wsl-utils
    thomshouse-ellipsis/chocolatey
);

# Load the metapackage functions
test -n "$PKG_PATH" && . "$PKG_PATH/src/meta.bash"

pkg.install() {
    # Add ellipsis bin to $PATH if it isn't there
    if [ ! "$(command -v ellipsis)" ]; then
        export PATH=$ELLIPSIS_PATH/bin:$PATH
    fi

    # Install packages
    meta.install_packages

    # Git LFS additional install step
    sh -c 'cd && git lfs install 2>/dev/null'

    # Run setup scripts
    for file in $(find "$PKG_PATH/setup" -maxdepth 1 -type f -name "*.sh"); do
        [ -e "$file" ] || continue
        PKG_PATH=$PKG_PATH sh "$file"
    done

    # Run full initialization
    meta.check_init_autoload
    pkg.init
}

pkg.init() {
    # Add ellipsis bin to $PATH if it isn't there
    if [ ! "$(command -v ellipsis)" ]; then
        export PATH=$ELLIPSIS_PATH/bin:$PATH
    fi

    # Add package bin to $PATH
    export PATH=$PKG_PATH/bin:$PATH

    # Initialize keychain if it's installed
    if [[ "$(command -v keychain)" ]]; then
            tput smcup
            eval `keychain -q --eval --agents ssh id_rsa`
            tput rmcup
    fi

    # Run init scripts
    for file in $(find "$PKG_PATH/init" -maxdepth 1 -type f -name "*.zsh"); do
        [ -e "$file" ] || continue
        . "$file"
    done
}

pkg.link() {
    fs.link_files links;
}
