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
    apt-get install -y aptitude vim fzf net-tools
    aptitude -y safe-upgrade

    while true; do
        echo "${GREEN}please enter desired hostname${ENDCOLR}"
        read HOSTNAME
        echo "setting hostname to: ${HOSTNAME}"
        hostname ${HOSTNAME}
        hostname -s > /etc/hostname
        sed -i "/127.0.0.1/ s/.*/127.0.0.1\t$(hostname) localhost $(hostname -s)/g" /etc/hosts
        break
    done
    
    echo "${GREEN}generate RSA ssh key${ENDCOLR}"
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -P ""

    echo "${GREEN}regenerate self-signed ssl${ENDCOLR}"
    apt-get install -y ssl-cert
    make-ssl-cert generate-default-snakeoil —-force-overwrite

    echo "${GREEN}Timezone and locale${ENDCOLR}"
    dpkg-reconfigure tzdata
    /usr/sbin/locale-gen es_MX.UTF-8

    echo "${GREEN}installing inputrc${ENDCOLR}"
    curl -s https://raw.githubusercontent.com/juparave/sysops/main/inputrc | cat > ~/.inputrc
    cp ~/.inputrc /etc/skel/

    echo "${GREEN}installing vimrc${ENDCOLR}"
    curl -s https://raw.githubusercontent.com/juparave/sysops/main/vimrc | cat > ~/.vimrc
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
    apt-get install -y python python-dev python3-pip python3-venv
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
    echo "${BLUE}installing mysql database server${ENDCOLR}"
    # You need to specify the 8.0 version number
    apt install -y mysql-server-core-8.0 mysql-server-8.0
}

install_php() {
    echo "${BLUE}install php support${ENDCOLR}"
    apt install -y php-fpm php-mysql php-xml php-mbstring

}

install_vimrc() {
    echo "${BLUE}install vimrc and plug"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    curl -s https://raw.githubusercontent.com/juparave/sysops/main/vimrc | cat > ~/.vimrc
}

install_certbot() {
    if [[ $WEBSERVER == "nginx" ]]; then
        # installing certbot for nginx
        apt install -y python3-certbot python3-certbot-nginx
    else
        if [[ $WEBSERVER == "apache" ]]; then
            die "not implemented for apache2, check phpmyadmin installation for $WEBSERVER"
        fi
    fi
}

install_phpmyadmin() {
    install_php
    # download and extract phpmyadmin to /var/www/html/phpmyadmin
    wget https://files.phpmyadmin.net/phpMyAdmin/5.1.1/phpMyAdmin-5.1.1-english.tar.gz
    tar zxvf phpMyAdmin-5.1.1-english.tar.gz -C /var/www/html/
    mv /var/www/html/phpMyAdmin-5.1.1-english /var/www/html/phpmyadmin

    if [[ $WEBSERVER == "nginx" ]]; then
        # uncommenting config file to enable php support
        sed -i "/#location.*php/ s/#//g" /etc/nginx/sites-enabled/default
        sed -i "/#.*include.*php.conf/ s/#//g" /etc/nginx/sites-enabled/default
        sed -i "/#.*fastcgi.*.sock/ s/#//g" /etc/nginx/sites-enabled/default
        # we still need to uncomment the closing bracket from this section `}`
        ## TODO
        sed -i "62s/#}$/}/g" /etc/nginx/sites-enabled/default
        sed -i "63s/#}$/}/g" /etc/nginx/sites-enabled/default
        sed -i "64s/#}$/}/g" /etc/nginx/sites-enabled/default
    else
        if [[ $WEBSERVER == "apache" ]]; then
            die "not implemented for apache2, check phpmyadmin installation for $WEBSERVER"
        fi
    fi
    # install ssl certificate for default server
    install_certbot
    certbot -d ${HOSTNAME}
}

install_mysql57() {
    # ref: https://computingforgeeks.com/how-to-install-mysql-on-ubuntu-focal/
    echo "${BLUE}installing mysql 5.7 database server${ENDCOLR}"
    wget https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb
    sudo dpkg -i mysql-apt-config_0.8.13-1_all.deb
    apt-get update
    apt install -y -f mysql-client=5.7* mysql-community-server=5.7* mysql-server=5.7*
}

install_postfix() {
    echo "${BLUE}installing postfix server${ENDCOLR}"
    apt-get install -y postfix
    while true; do
        read -p "${GREEN}Enter root email alias${ENDCOLR} " ROOTALIAS
        #sed -i "/root:/ s/.*/root:\t\t${ROOTALIAS}/g" /etc/aliases
        echo -e "root:\t\t${ROOTALIAS}" >> /etc/aliases
        echo "${GREEN}default email aliases${ENDCOLR}"
        cat /etc/aliases
        break
    done
}

install_languages
install_mysql57
WEBSERVER=$(echo "apache2 nginx" | tr " " "\n" | fzf)
install_webserver
install_phpmyadmin
install_postfix
install_vimrc

echo "${GREEN}All installations are done!${ENDCOLR}"
echo "${RED}reboot is recomended${ENDCOLR}"
touch STEP_02
