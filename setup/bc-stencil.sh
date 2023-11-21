#!/bin/bash

# Install NVM
if [ ! "$(command -v nvm)" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
fi

# Initialize NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm

# Configure NVM for Stencil
nvm install 18
nvm use 18
nvm alias default 18

# Install Stencil CLI
if [ ! "$(command -v stencil)" ]; then
    npm install -g @bigcommerce/stencil-cli
else
    npm update -g @bigcommerce/stencil-cli
fi