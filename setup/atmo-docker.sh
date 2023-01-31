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

    # Check to see if DNS is set
    LOCALHOST_IN_DNS=0;
    DNS_OS_PREFIX="";
    case "$(ellipsis api os.platform)" in
        wsl1|wsl2)
            DNS_OS_PREFIX=" Windows"
            if [ $(ipconfig.exe /all | grep "DNS Servers.*127\.0\.0\.1" | wc -l) -gt 0 ]; then
                LOCALHOST_IN_DNS=1;
            fi
            ;;
        macos)
            if [ $(scutil --dns | grep "nameserver.*127\.0\.0\.1" | wc -l) -gt 0 ]; then
                LOCALHOST_IN_DNS=1;
            fi
            ;;
        *)
            if [ $(cat /etc/resolv.conf | grep "nameserver.*127\.0\.0\.1" | wc -l) -gt 0 ]; then
                LOCALHOST_IN_DNS=1;
            fi
            ;;
    esac
    if [[ (! -f "$PKG_PATH/.no-dns-prompt") && ($LOCALHOST_IN_DNS -eq 0) ]]; then
        echo "The atmosol Docker environment requires additional DNS configuration at the host level:"
        echo ""
        echo "Please set your$DNS_OS_PREFIX network settings to include localhost as a primary DNS server."
        echo "You may want to set your secondary DNS server to 8.8.8.8 (Google) or 1.1.1.1 (Cloudflare)."
        echo ""
        echo "Example:"
        echo "  Primary DNS:    127.0.0.1"
        echo "  Secondary DNS:    8.8.8.8"
        echo ""
        read -e -p "Do you want more information about this? [y/N/never] " DNS_MORE_INFO
        if [[ $DNS_MORE_INFO =~ ^[Yy]([Ee][Ss])? ]]; then
            # Optionally open up Bitbucket URLs if supported
            if [ -z "$BROWSER" ]; then
                # Look for common browsers/OS support if not set in environment
                browsers=( "explorer.exe" "open" "xdg-open" "gnome-open" "browsh" "w3m" "links2" "links" "lynx" )
                for b in "${browsers[@]}"; do
                    if [ "$(command -v $b)" ]; then
                        BROWSER="$b"
                        break
                    fi
                done
            fi
            if [ -n "$BROWSER" ]; then
                echo -e "\nOpening Bitbucket SSH Keys page...\n"
                $BROWSER "https://geekflare.com/change-dns-server/"
            else
                echo "-e\nPlease visit this URL for more information:\n  https://geekflare.com/change-dns-server/\n"
                read -n 1 -s -r -p "Press any key to continue..."
                read -s -t 0 # Clear any extra keycodes (e.g. arrows)
            fi
        elif [[ $DNS_MORE_INFO =~ ^[Nn][Ee][Vv][Ee][Rr]$ ]]; then
            touch "$PKG_PATH/.no-dns-prompt"
        fi
    fi
fi