## Nextcloud-Installer
With this script you can set up Nextcloud on your server. It is done quickly, easily and safely.

Please note that this script is made to work on a fresh installation. There is a good chance that it will fail if it is not a fresh installation.
The script must be run as root.

If you find any errors, things you would like changed or queries for things in the future for this script, please write an "Issue".
(Please do NOT use this script yet, it is not done.)

## Features

- Install Nextcloud
- Uninstall Nextcloud

## Supported OS & Webserver
Supported operating systems.

| Operating System | Version               | Supported                          |
| ---------------- | ----------------------| ---------------------------------- |
| Ubuntu           | from 18.04 to 22.04   | :white_check_mark:                 |
| Debian           | from 10 to 11         | :white_check_mark:                 |
| CentOS           | no supported versions | :x:                                |
| Rocky Linux      | no supported versions | :x:                                |

| Webserver        | Supported           |
| ---------------- | --------------------| 
| NGINX            | :white_check_mark:  |
| Apache           | :x:                 |
| LiteSpeed        | :x:                 |
| Caddy            | :x:                 |

## Copyright
You have no right to say that you created this script. You may create a fork for this Nextcloud-Installer, but this github must always be linked to.
Also, do not remove my copyright at the top of the Nextcloud-Installer script.

## Support
No support is offered for this script.
The script has been tested many times without any bug fixes, however they can still occur.
If you find errors, feel free to open an "Issue" on GitHub.

# Run the script
Debian based systems only.
```bash
bash <(curl -s https://raw.githubusercontent.com/guldkage/Nextcloud-Installer/main/installer.sh)
```

### Raspbian
Only for raspbian users. They might need a extra < in the beginning.
```bash
bash < <(curl -s https://raw.githubusercontent.com/guldkage/Nextcloud-Installer/main/installer.sh)
```
