#!/bin/bash

# Install NVM
if [ ! "$(command -v nvm)" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
fi

# Configure NVM for Stencil
nvm install 12
nvm use 12
nvm alias default 12

# Install Stencil CLI
if [ ! "$(command -v stencil)" ]; then
    npm install -g @bigcommerce/stencil-cli
fi