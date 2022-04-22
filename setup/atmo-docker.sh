#!/bin/bash

if [ ! -x "$(command -v docker)" ]; then
    echo ""
    echo "ERROR: Docker not detected. Installation requires presence of docker command."
    echo ""
elif [ ! -x "$(command -v mutagen)" ] && [ "$(uname -s)" = "Darwin" ]; then
    echo ""
    echo "WARNING: You do not have mutagen installed. Files may not be properly syned to Docker container."
    echo ""
    read -n 1 -s -r -p "Press any key to continue or Ctrl+C to quit."
    echo ""
    echo ""
else

    # Start dnsmasq and traefik
    docker network create traefik_default >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Created traefik_default docker network."
    else
        docker network inspect traefik_default >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Docker network traefik_default already exists."
        else
            echo "Error creating traefik_default docker network."
        fi
    fi

    # Check to see if dnsmasq is running...
    cd "$PKG_PATH/src/dnsmasq"
    docker inspect dnsmasq >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        # Restart it if it's running
        docker-compose down >/dev/null 2>&1 && echo "Stopping dnsmasq..." \
            && docker-compose up -d >/dev/null 2>&1 && echo "Restarting dnsmasq..."
    else
        # Start it if it's not running
        docker-compose up -d >/dev/null 2>&1 && echo "Starting dnsmasq..."
    fi
    [ $? -ne 0 ] && echo "Error restarting dnsmasq!" 1>&2

    # Check to see if traefik is running...
    cd "$PKG_PATH/src/traefik"
    docker inspect traefik_reverse-proxy_1 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        # Restart it if it's running
        docker-compose down >/dev/null 2>&1; echo "Stopping traefik..." # docker down will error because of the network
        docker-compose up -d >/dev/null 2>&1 && echo "Restarting traefik..."
    else
        # Start it if it's not running
        docker-compose up -d >/dev/null 2>&1 && echo "Starting traefik..."
    fi
    [ $? -ne 0 ] && echo "Error restarting traefik!" 1>&2
fi