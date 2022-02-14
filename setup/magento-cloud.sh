#!/bin/zsh

if (( $+commands[magento-cloud] )); then
	magento-cloud self:update;
else
	curl -sS https://accounts.magento.cloud/cli/installer | php
fi
