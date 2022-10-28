#!/bin/bash
#!/usr/bin/env bash

########################################################################
#                                                                      #
#            Nextcloud Installer                                       #
#            Copyright 2022, Malthe K, <me@malthe.cc>                  #
# https://github.com/guldkage/Nextcloud-Installer/blob/main/LICENSE    #
#                                                                      #
#  This script is not associated with Nextcloud GmbH                   #
#  You may not remove this line                                        #
#                                                                      #
########################################################################

### VARIABLES ###

dist="$(. /etc/os-release && echo "$ID")"
CONTINUE_ANYWAY=""
FQDN=""

### OUTPUTS ###

output(){
    echo -e '\e[36m'"$1"'\e[0m';
}

function trap_ctrlc ()
{
    output "Bye!"
    exit 2
}
trap "trap_ctrlc" 2

warning(){
    echo -e '\e[31m'"$1"'\e[0m';
}

### OS Check ###

oscheck(){
    output "* Checking your OS.."
    if  [ "$dist" =  "ubuntu" ] ||  [ "$dist" =  "debian" ]; then
        output "* Your OS, $dist, is fully supported. Continuing.."
        output ""
        options
    elif  [ "$dist" =  "fedora" ] ||  [ "$dist" =  "centos" ] || [ "$dist" =  "rhel" ] || [ "$dist" =  "rocky" ] || [ "$dist" = "almalinux" ]; then
        output "* Your OS, $dist, is not fully supported."
        output "* Installations may work, but there is no gurrantee."
        output "* Continuing in 5 seconds. CTRL+C to stop."
        output ""
        sleep 5s
        options
    else
        output "* Your OS, $dist, is not supported!"
        output "* Exiting..."
        exit 1
    fi
}

## Install Nextloud ##

install-begin(){
    output ""
    output "Enter the address you want to access Nextcloud with. This could be an FQDN or an IP address."
    output "For security, we recommend that you use an FQDN with a security certificate that this script can create after this point."
    output "Make sure that your FQDN is pointed to your IP with an A record. If not the script will not be able to provide the webpage."
    read -r FQDN
    [ -z "$FQDN" ] && output "FQDN can't be empty."
    IP=$(dig +short myip.opendns.com @resolver2.opendns.com -4)
    DOMAIN=$(dig +short ${FQDNPHPMYADMIN})
    if [ "${IP}" != "${DOMAIN}" ]; then
        output ""
        output "Your FQDN does not resolve to the IP of current server."
        output "Please point your servers IP to your FQDN."
        install-begin-fqdnnotpointed
    else
        output "Your FQDN is pointed correctly. Continuing."
        phpmyadmininstall
    fi
}

install-begin-fqdnnotpointed(){
    output ""
    output "This error can sometimes be false positive."
    output "Do you want to continue anyway?"
    output "(Y/N):"
    read -r CONTINUE_ANYWAY

    if [[ "$CONTINUE_ANYWAY" =~ [Yy] ]]; then
        required
    fi
    if [[ "$CONTINUE_ANYWAY" =~ [Nn] ]]; then
        exit 1
    fi
}


### Options ###

options(){
    output "Please select your installation option:"
    warning "[1] Install Nextcloud. | Install the latest version of Nextcloud."
    warning "[2] Uninstall Nextcloud. | Uninstalls Nextcloud. This includes your personal files on it too."
    read -r option
    case $option in
        1 ) option=1
            install-begin
            ;;
        2 ) option=2
            uninstall-begin
            ;;
        * ) output ""
            output "Please enter a valid option from 1-10"
    esac
}

### Start ###

clear
output ""
warning "Nextcloud Installer @ v2.0"
warning "Copyright 2022, Malthe K, <me@malthe.cc>"
warning "https://github.com/guldkage/Nextcloud-Installer"
warning ""
warning "This script is not responsible for any damages. The script has been tested several times without issues."
warning "Support is not given."
warning "This script will only work on a fresh installation. Proceed with caution if not having a fresh installation"
warning ""
warning "You are very welcome to report errors or bugs about this script. These can be reported on GitHub."
warning "Thanks in advance!"
warning ""
oscheck
