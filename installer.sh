#!/bin/bash
#!/usr/bin/env bash

########################################################################
#                                                                      #
#            Nextcloud Installer                                       #
#            Copyright 2022, Malthe K, <me@malthe.cc>                  #
#  https://github.com/guldkage/Nextcloud-Installer/blob/main/LICENSE   #
#                                                                      #
#  This script is not associated with Nextcloud GmbH                   #
#  You may not remove this line                                        #
#                                                                      #
########################################################################

### VARIABLES ###

dist="$(. /etc/os-release && echo "$ID")"
CONTINUE_ANYWAY=""
FQDN=""
SSL_CONFIRM=""
EMAIl=""

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

email-ssl(){
    output ""
    output "Because you chose to protect your Nextcloud instance with SSL, your email address must be used to create an SSL certificate."
    output "Your email will be forwarded to Let's Encrypt. If you do not agree, stop the script."
    output ""
    output "Please enter your email"
    read -r EMAIL
    required-ssl
}

ssl(){
    output ""
    output "Do you want to use SSL for Nextcloud? This requires a domain."
    output "Use of SSL is always recommended as the connection is not encrypted without SSL."
    output "Your personal files will therefore be safest with an SSL connection."
    output "(Y/N):"
    read -r SSL_CONFIRM

    if [[ "$SSL_CONFIRM_PHPMYADMIN" =~ [Yy] ]]; then
        email-ssl
        fi
    if [[ "$SSL_CONFIRM_PHPMYADMIN" =~ [Nn] ]]; then
        required
        fi
}

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
        required
    fi
}

required-ssl(){
    output ""
    output "Starting the installation of Nextcloud"
    sleep 1s
    if  [ "$dist" =  "ubuntu" ] || [ "$dist" =  "debian" ]; then
        apt update
        apt install nginx certbot unzip mariadb-server -y
        cd /var/www/ || exit || output "An error occurred. Could not enter the directory." || exit
        wget https://download.nextcloud.com/server/releases/latest.zip
        sudo unzip latest.zip -d /var/www/nextcloud
        sudo chown www-data:www-data /var/www/nextcloud -R
        DBPASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
        mysql -u root -e "CREATE USER 'nextcloud'@'127.0.0.1' IDENTIFIED BY '$DBPASSWORD';" && mysql -u root -e "CREATE DATABASE nextcloud;" && mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'nextcloud'@'127.0.0.1' WITH GRANT OPTION;"

        curl -o /etc/nginx/sites-enabled/nextcloud.conf https://raw.githubusercontent.com/guldkage/Nextcloud-Installer/main/nextcloud.conf
        sed -i -e "s@<domain>@${FQDN}@g" /etc/nginx/sites-enabled/nextcloud.conf
        systemctl stop nginx && certbot certonly --standalone -d $FQDN --staple-ocsp --no-eff-email -m $EMAIL --agree-tos && systemctl start nginx

    elif  [ "$dist" =  "fedora" ] ||  [ "$dist" =  "centos" ] || [ "$dist" =  "rhel" ] || [ "$dist" =  "rocky" ] || [ "$dist" = "almalinux" ]; then
        test....
    fi
}

required(){
    output ""
    output "Starting the installation of Nextcloud"
    sleep 1s
    if  [ "$dist" =  "ubuntu" ] || [ "$dist" =  "debian" ]; then
        apt update
        apt install nginx unzip mariadb-server -y
        cd /var/www/ || exit || output "An error occurred. Could not enter the directory." || exit
        wget https://download.nextcloud.com/server/releases/latest.zip
        sudo unzip latest.zip -d /var/www/nextcloud
        sudo chown www-data:www-data /var/www/nextcloud -R
        DBPASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
        mysql -u root -e "CREATE USER 'nextcloud'@'127.0.0.1' IDENTIFIED BY '$DBPASSWORD';" && mysql -u root -e "CREATE DATABASE nextcloud;" && mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'nextcloud'@'127.0.0.1' WITH GRANT OPTION;"

        curl -o /etc/nginx/sites-enabled/nextcloud.conf https://raw.githubusercontent.com/guldkage/Nextcloud-Installer/main/nextcloud.conf
        systemctl restart nginx

    elif  [ "$dist" =  "fedora" ] ||  [ "$dist" =  "centos" ] || [ "$dist" =  "rhel" ] || [ "$dist" =  "rocky" ] || [ "$dist" = "almalinux" ]; then
        test....
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
    output "[1] Install Nextcloud. | Install the latest version of Nextcloud."
    output "[2] Uninstall Nextcloud. | Uninstalls Nextcloud. This includes your personal files on it too."
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
