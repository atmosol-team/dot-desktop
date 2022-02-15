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

    RECOMMEND_RELOAD=0

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
    cd "$PKG_PATH/src/dnsmasq" && docker-compose up -d >/dev/null 2>&1 && echo "Dockerized dnsmasq service started."
    cd "$PKG_PATH/src/traefik" && docker-compose up -d >/dev/null 2>&1 && echo "Dockerized traefik service started."

    # 
    if [ $RECOMMEND_RELOAD -ne 0 ]; then
        echo ""
        echo "It's strongly recommended that you close and reopen your terminal at this time."
        echo ""
    fi
fi