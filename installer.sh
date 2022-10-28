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

### Options ###

options(){
    output "Please select your installation option:"
    warning "[1] Install Panel. | Installs latest version of Pterodactyl Panel"
    warning "[2] Install Wings. | Installs latest version of Pterodactyl Wings."
    warning "[3] Install PHPMyAdmin. | Installs PHPMyAdmin. (Installs using NGINX)"
    warning ""
    warning "[4] Update Panel. | Updates your Panel to the latest version. May remove addons and themes."
    warning "[5] Update Wings. | Updates your Wings to the latest version."
    warning ""
    warning "[6] Uninstall Wings. | Uninstalls your Wings. This will also remove all of your game servers."
    warning "[7] Uninstall Panel. | Uninstalls your Panel. You will only be left with your database and web server."
    warning ""
    warning "[8] Renew Certificates | Renews all Lets Encrypt certificates on this machine."
    warning "[9] Configure Firewall | Configure UFW to your liking."
    warning "[10] Switch Pterodactyl Domain | Changes your Pterodactyl Domain."
    read -r option
    case $option in
        1 ) option=1
            start
            ;;
        2 ) option=2
            startwings
            ;;
        3 ) option=3
            startphpmyadmin
            ;;
        4 ) option=4
            updatepanel
            ;;
        5 ) option=5
            updatewings
            ;;
        6 ) option=6
            uninstallwings
            ;;
        7 ) option=7
            uninstallpanel
            ;;
        8 ) option=8
            renewcertificates
            ;;
        9 ) option=9
            configureufw
            ;;
        10 ) option=10
            switchdomains
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
