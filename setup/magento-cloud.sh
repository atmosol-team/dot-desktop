#!/usr/bin/env bash

if [ ! "$(command -v magento-coud)" ]; then
	magento-cloud self:update;
else
	curl -sS https://accounts.magento.cloud/cli/installer | php
fi
