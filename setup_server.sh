#!/usr/bin/env bash

# call it using curl, $RANDOM is used to avoid server cache
# curl -s https://raw.githubusercontent.com/juparave/sysops/main/setup_server.sh?$RANDOM | bash

RED=$(tput setaf 160)
GREEN=$(tput setaf 76)
BLUE=$(tput setaf 123)
ENDCOLR=$(tput setaf 7)

# Install a new server with common apps
# Assuming this is an Ubuntu distro

if [ ! -f "STEP_01" ]; then
    echo "${BLUE}Updating instance${ENDCOLR}"
    apt-get update
    aptitude -y safe-upgrade
    apt-get install -y aptitude vim fzf net-tools

    while true; do
        echo "${GREEN}please enter desired hostname${ENDCOLR}"
        read hn
        echo "setting hostname to: ${hn}"
        hostname ${hn}
        hostname -s > /etc/hostname
        sed -i "/127.0.0.1/ s/.*/127.0.0.1\t$(hostname) localhost $(hostname -s)/g" /etc/hosts
        break
    done
    
    echo "${GREEN}regenerate self-signed ssl${ENDCOLR}"
    apt-get install -y ssl-cert
    make-ssl-cert generate-default-snakeoil —force-overwrite

    echo "${GREEN}Timezone and locale${ENDCOLR}"
    dpkg-reconfigure tzdata
    /usr/sbin/locale-gen es_MX.UTF-8

    echo "${GREEN}installing inputrc${ENDCOLR}"
    curl -s https://raw.githubusercontent.com/juparave/sysops/main/inputrc | cat > ~/.inputrc
    cp ~/.inputrc /etc/skel/

    echo "${BLUE}Please reboot to finish step 01${ENDCOLR}"
    touch STEP_01
    exit 0
fi

if [ -f "STEP_02" ]; then
    echo "${RED}Seems like all steps are already done${ENDCOLR}"
    exit 0
fi

install_languages() {
    echo "${BLUE}installing programming languages python and go${ENDCOLR}"
    apt-get install -y python python-dev python-pip
    apt-get install -y golang
}

install_nginx() {
    echo "${BLUE}installing nginx webserver${ENDCOLR}"
    apt-get install -y nginx
}

install_apache2() {
    echo "${BLUE}installing apache2 webserver${ENDCOLR}"
    apt-get install -y apache2
}

install_webserver() {
    if [[ $WEBSERVER == "nginx" ]]; then
        install_nginx
    else
        if [[ $WEBSERVER == "apache" ]]; then
            install_apache
        else
            die "unknown webserver $WEBSERVER"
        fi
    fi
}

install_mysql() {
    echo "${BLUE}installing mysql database server"
    apt-get install -y mysql-server
}

install_postfix() {
    echo "${BLUE}installing postfix server${ENDCOLR}"
    apt-get install -y postfix
    read -p "Enter root email alias" ROOTALIAS
    sed -i "/root:/ s/.*/root:\t\t${ROOTALIAS}/g" /etc/aliases
    echo "${GREEN}default email aliases${ENDCOLR}"
    cat /etc/aliases
}

install_languages
install_mysql
WEBSERVER=$(echo "apache2 nginx" | tr " " "\n" | fzf)
install_webserver
install_postfix

echo "${GREEN}All installations are done!${ENDCOLR}"
echo "${RED}reboot is recomended${ENDCOLR}"
touch STEP_02
