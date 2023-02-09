#!/bin/bash
#!/usr/bin/env bash

########################################################################
#                                                                      #
#            Nextcloud Installer                                       #
#            Copyright 2022, Malthe K, <me@malthe.cc>                  #
#  https://github.com/guldkage/Nextcloud-Installer/blob/main/LICENSE   #
#                                                                      #
#  This script is not associated with Nextcloud GmbH                   #
#                                                                      #
########################################################################

### VARIABLES ###

dist="$(. /etc/os-release && echo "$ID")"
CONTINUE_ANYWAY=""
FQDN=""
SSL_CONFIRM=""
EMAIl=""
DBPASSWORD=""

IP=""
DBDATABASE=""
DBUSERNAME=""
FOLDER=""

UNINSTALL_CONFIRM=""
UNINSTALL=""

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

    if [[ "$SSL_CONFIRM" =~ [Yy] ]]; then
        email-ssl
        fi
    if [[ "$SSL_CONFIRM" =~ [Nn] ]]; then
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
    IP=$(dig +short myip.opendns.com @resolver1.opendns.com -4)
    DOMAIN=$(dig +short ${FQDNPHPMYADMIN})
    if [ "${IP}" != "${DOMAIN}" ]; then
        output ""
        output "Your FQDN does not resolve to the IP of current server."
        output "Please point your servers IP to your FQDN."
        install-begin-fqdnnotpointed
    else
        output "Your FQDN is pointed correctly. Continuing."
        ssl
    fi
}

required-ssl(){
    output ""
    output "Starting the installation of Nextcloud"
    sleep 1s
    if  [ "$dist" =  "ubuntu" ]; then
        apt update
        LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        apt update
        apt install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} nginx certbot unzip mariadb-server -y
        cd /var/www/ || exit || output "An error occurred. Could not enter the directory." || exit
        wget https://download.nextcloud.com/server/releases/latest.zip
        sudo unzip latest.zip -d /var/www/
        sudo chown www-data:www-data /var/www/nextcloud -R
        output "Configuring MySQL"
        DBPASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
        mysql -u root -e "CREATE USER 'nextcloud'@'127.0.0.1' IDENTIFIED BY '$DBPASSWORD';" && mysql -u root -e "CREATE DATABASE nextcloud;" && mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'nextcloud'@'127.0.0.1' WITH GRANT OPTION;"

        output "Configuring webserver"
        rm /etc/nginx/sites-enabled/default
        curl -o /etc/nginx/sites-enabled/nextcloud.conf https://raw.githubusercontent.com/guldkage/Nextcloud-Installer/main/nextcloud-ssl.conf
        sed -i -e "s@<domain>@${FQDN}@g" /etc/nginx/sites-enabled/nextcloud.conf
        systemctl stop nginx && certbot certonly --standalone -d $FQDN --staple-ocsp --no-eff-email -m $EMAIL --agree-tos && systemctl start nginx

        clear
        output "Installation successful"
        output "Your Nextcloud instance should be available at"
        output "https://${FQDN} or http://${FQDN} depending if you chose SSL or not."
        output ""
        output "For security reasons,"
        output "you must set up the rest of Nextcloud yourself."
        output "To make it easy for you,"
        output "everything you have to enter on the website is listed below."
        output ""
        output "Username: Select yourself"
        output "Password: Select yourself"
        output ""
        output "Database host: 127.0.0.1"
        output "Database name: nextcloud"
        output "User: nextcloud"
        output "User password: $DBPASSWORD"

    elif  [ "$dist" =  "debian" ]; then
        apt update
        apt -y install software-properties-common curl ca-certificates gnupg2 curl sudo lsb-release
        echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
        curl -fsSL  https://packages.sury.org/php/apt.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/sury-keyring.gpg

        apt update
        apt install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} nginx certbot unzip mariadb-server -y
        cd /var/www/ || exit || output "An error occurred. Could not enter the directory." || exit
        wget https://download.nextcloud.com/server/releases/latest.zip
        sudo unzip latest.zip -d /var/www/
        sudo chown www-data:www-data /var/www/nextcloud -R
        output "Configuring MySQL"
        DBPASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
        mysql -u root -e "CREATE USER 'nextcloud'@'127.0.0.1' IDENTIFIED BY '$DBPASSWORD';" && mysql -u root -e "CREATE DATABASE nextcloud;" && mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'nextcloud'@'127.0.0.1' WITH GRANT OPTION;"

        output "Configuring webserver"
        rm /etc/nginx/sites-enabled/default
        curl -o /etc/nginx/sites-enabled/nextcloud.conf https://raw.githubusercontent.com/guldkage/Nextcloud-Installer/main/nextcloud-ssl.conf
        sed -i -e "s@<domain>@${FQDN}@g" /etc/nginx/sites-enabled/nextcloud.conf
        systemctl stop nginx && certbot certonly --standalone -d $FQDN --staple-ocsp --no-eff-email -m $EMAIL --agree-tos && systemctl start nginx

        clear
        output "Installation successful"
        output "Your Nextcloud instance should be available at"
        output "https://${FQDN} or http://${FQDN} depending if you chose SSL or not."
        output ""
        output "For security reasons,"
        output "you must set up the rest of Nextcloud yourself."
        output "To make it easy for you,"
        output "everything you have to enter on the website is listed below."
        output ""
        output "Username: Select yourself"
        output "Password: Select yourself"
        output ""
        output "Database host: 127.0.0.1"
        output "Database name: nextcloud"
        output "User: nextcloud"
        output "User password: $DBPASSWORD"
    fi
}

required(){
    output ""
    output "Starting the installation of Nextcloud"
    sleep 1s
    if  [ "$dist" =  "ubuntu" ]; then
        apt update
        LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        apt update
        apt install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} nginx unzip mariadb-server -y

        cd /var/www/ || exit || output "An error occurred. Could not enter the directory." || exit
        wget https://download.nextcloud.com/server/releases/latest.zip
        sudo unzip latest.zip -d /var/www/
        sudo chown www-data:www-data /var/www/nextcloud -R
        output "Configuring MySQL"
        DBPASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
        mysql -u root -e "CREATE USER 'nextcloud'@'127.0.0.1' IDENTIFIED BY '$DBPASSWORD';" && mysql -u root -e "CREATE DATABASE nextcloud;" && mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'nextcloud'@'127.0.0.1' WITH GRANT OPTION;"

        output "Configuring webserver"
        rm /etc/nginx/sites-enabled/default
        curl -o /etc/nginx/sites-enabled/nextcloud.conf https://raw.githubusercontent.com/guldkage/Nextcloud-Installer/main/nextcloud.conf
        sed -i -e "s@<domain>@${FQDN}@g" /etc/nginx/sites-enabled/nextcloud.conf
        systemctl restart nginx

        clear
        output "Installation successful"
        output "Your Nextcloud instance should be available at"
        output "https://${FQDN} or http://${FQDN} depending if you chose SSL or not."
        output ""
        output "For security reasons,"
        output "you must set up the rest of Nextcloud yourself."
        output "To make it easy for you,"
        output "everything you have to enter on the website is listed below."
        output ""
        output "Username: Select yourself"
        output "Password: Select yourself"
        output ""
        output "Database host: 127.0.0.1"
        output "Database name: nextcloud"
        output "User: nextcloud"
        output "User password: $DBPASSWORD"

    elif  [ "$dist" =  "debian" ]; then
        apt update
        apt -y install software-properties-common curl ca-certificates gnupg2 curl sudo lsb-release
        echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
        curl -fsSL  https://packages.sury.org/php/apt.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/sury-keyring.gpg
        apt update
        apt install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} nginx unzip mariadb-server -y

        cd /var/www/ || exit || output "An error occurred. Could not enter the directory." || exit
        wget https://download.nextcloud.com/server/releases/latest.zip
        sudo unzip latest.zip -d /var/www/
        sudo chown www-data:www-data /var/www/nextcloud -R
        output "Configuring MySQL"
        DBPASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
        mysql -u root -e "CREATE USER 'nextcloud'@'127.0.0.1' IDENTIFIED BY '$DBPASSWORD';" && mysql -u root -e "CREATE DATABASE nextcloud;" && mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'nextcloud'@'127.0.0.1' WITH GRANT OPTION;"

        output "Configuring webserver"
        rm /etc/nginx/sites-enabled/default
        curl -o /etc/nginx/sites-enabled/nextcloud.conf https://raw.githubusercontent.com/guldkage/Nextcloud-Installer/main/nextcloud.conf
        sed -i -e "s@<domain>@${FQDN}@g" /etc/nginx/sites-enabled/nextcloud.conf
        systemctl restart nginx

        clear
        output "Installation successful"
        output "Your Nextcloud instance should be available at"
        output "https://${FQDN} or http://${FQDN} depending if you chose SSL or not."
        output ""
        output "For security reasons,"
        output "you must set up the rest of Nextcloud yourself."
        output "To make it easy for you,"
        output "everything you have to enter on the website is listed below."
        output ""
        output "Username: Select yourself"
        output "Password: Select yourself"
        output ""
        output "Database host: 127.0.0.1"
        output "Database name: nextcloud"
        output "User: nextcloud"
        output "User password: $DBPASSWORD"
    fi
}

install-begin-fqdnnotpointed(){
    output ""
    output "This error can sometimes be false positive."
    output "Do you want to continue anyway?"
    output "(Y/N):"
    read -r CONTINUE_ANYWAY

    if [[ "$CONTINUE_ANYWAY" =~ [Yy] ]]; then
        ssl
    fi
    if [[ "$CONTINUE_ANYWAY" =~ [Nn] ]]; then
        exit 1
    fi
}

uninstall-begin(){
    output ""
    output "Are you sure you want to delete your Nextcloud instance from this machine?"
    output "This deletes the entire Nextcloud collection of all your files stored in Nextcloud."
    output "If you, for example, have images stored on your Nextcloud, they will be deleted permanently."
    output ""
    output "If you still want Nextcloud deleted, we need some more information about your installation of Nextcloud."
    output ""
    output "(Y/N):"
    read -r UNINSTALL

    if [[ "$UNINSTALL" =~ [Yy] ]]; then
        uninstall-ip
        fi
    if [[ "$SSL_CONFIRM" =~ [Nn] ]]; then
        output "Uninstall aborted"
        fi
}

uninstall-ip(){
    output ""
    output "Please enter your MySQL Bind IP that was used for Nextcloud. If you used this script installing Nextcloud, the bind IP will be 127.0.0.1"
    read -r ip
    IP=$ip
    uninstall-folder
}

uninstall-folder(){
    output ""
    output "Please enter your directory where Nextcloud is installed. If you used this script installing Nextcloud, the directory will be /var/www/nextcloud."
    output "Do NOT enter / here. It will wipe your whole system."
    read -r folder

    if [[ "$folder" =~ [/] ]]; then
        output "No. You cannot wipe your own system."
    else
        FOLDER=$folder
        uninstall-dbdatabase
    fi
}

uninstall-dbdatabase(){
    output ""
    output "Please enter your MySQL Nextcloud database. If you used this script installing Nextcloud, the database will be nextcloud."
    read -r dbdatabase
    DBDATABASE=$dbdatabase
    uninstall-dbusername
}

uninstall-dbusername(){
    output ""
    output "Please enter your MySQL Nextcloud username. If you used this script installing Nextcloud, the username will be nextcloud."
    read -r dbusername
    DBUSERNAME=$dbusername
    uninstall-confirm
}

uninstall-confirm(){
    output ""
    output "Last warning: Nextcloud will be deleted."
    output "Run at your own risk."
    output ""
    output "(Y/N):"
    read -r UNINSTALL_CONFIRM

    if [[ "$UNINSTALL_CONFIRM" =~ [Yy] ]]; then
        output ""
        output "Uninstalling Nextcloud"
        output ""
        output "Removing files"
        rm -rf $folder
        output "Removing database"
        mysql -u root -e "DROP USER '$dbusername'@'$ip';" && mysql -u root -e "DROP DATABASE $dbdatabase;"
        output "Removing configs"
        rm /etc/nginx/sites-enabled/nextcloud.conf
        rm /etc/nginx/sites-available/nextcloud.conf
        rm /etc/nginx/conf.d/nextcloud.conf
        output ""
        output "Nextcloud uninstalled."
        fi
    if [[ "$UNINSTALL_CONFIRM" =~ [Nn] ]]; then
        output "Uninstall aborted"
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
            output "Please enter a valid option from 1-2"
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
