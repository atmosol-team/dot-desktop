#!/bin/zsh
export PATH=$PATH:$HOME/.magento-cloud/bin

if [[ -a ~/.magento-cloud/shell-config.rc ]]; then
	. ~/.magento-cloud/shell-config.rc;
fi
