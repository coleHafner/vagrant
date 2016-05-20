#friendly up passed vars
MYSQL_PASSWORD="vagrant"

IP=$1
HOST=$2
SERVER_DIR=$3
CLIENT_DIR=$4

DOC_ROOT="/var/www/$HOST"
VAGRANT_ROOT="$DOC_ROOT/vagrant"
SERVER_ROOT=$([ "$SERVER_DIR" == '' ] && echo "$DOC_ROOT" || echo "$DOC_ROOT/$SERVER_DIR")
CLIENT_ROOT=$([ "$CLIENT_DIR" == '' ] && echo "$DOC_ROOT" || echo "$DOC_ROOT/$CLIENT_DIR")


#Prevent debconf from having to look for stdin
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<< "grub-pc	grub-pc/install_devices	multiselect	/dev/sda"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"

#LAMP SETUP

# update / upgrade
sudo apt-get update
sudo apt-get -y upgrade

# install apache 2.x and php 5.x
sudo apt-get install -y apache2
sudo apt-get install -y php5
sudo apt-get install libapache2-mod-php5

# install php dev tools (necessary for some other shit)
sudo apt-get install -y php5-dev

# install mysql
sudo apt-get install -y mysql-server
sudo apt-get install -y php5-mysqlnd

#LAMP EXTRAS

# install gd and/or image magic
sudo apt-get install -y php5-gd

# install dumb old mcrypt
sudo apt-get install -y mcrypt php5-mcrypt
sudo php5enmod mcrypt

# install imap for php
sudo apt-get install -y libc-client-dev
sudo apt-get install -y php5-imap
sudo php5enmod imap

# install curl
sudo apt-get install -y curl
sudo apt-get install -y php5-curl

#install server utils
sudo apt-get install -y vim
sudo apt-get install -y htop

# enable apache mods
sudo a2enmod headers
sudo a2enmod php5
sudo a2enmod rewrite

# install latest version of git
sudo apt-add-repository -y ppa:git-core/ppa
sudo apt-get -y update
sudo apt-get -y install git

if [ "$CLIENT_DIR" != '' ]; then
	# install node.js
	curl -sL https://deb.nodesource.com/setup | sudo bash -
	sudo apt-get -y install nodejs

	# install latest npm
	sudo npm -g install npm@latest

	# install grunty-grunt
	sudo npm install -g grunt-cli

	# install grunt & bower
	sudo npm install -g bower

	# yo scaffolding tool
	# sudo npm install -g yo
	# sudo npm install -g generator-angular

	# ruby and some other shiz
	sudo apt-get -y install ruby-dev libsqlite3-dev

	# libsass is used for sass processing... which is part of the npm install
	# sudo gem install compass
fi

# VHOST CONFIG
# setup hosts file
VHOST=$(cat <<EOF
<Directory $SERVER_ROOT>
    AllowOverride All
    Order Allow,Deny
    Allow from All
</Directory>
<VirtualHost *:80>
    ServerName $HOST
    DocumentRoot $SERVER_ROOT
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/$HOST.conf

#start site
sudo a2dissite 000-default.conf
sudo a2ensite $HOST.conf

sudo service apache2 reload

# COMPOSER PACKAGE INSTALL

if [ -e "$SERVER_ROOT/composer.json" ]; then
	cd $VAGRANT_ROOT/provisions
	sudo ./scripts/install-composer.sh

	# COMPOSER DEPENDENCIES INSTALL
	cd $SERVER_ROOT
	composer install
fi


if [ -d "$SERVER_ROOT/vendor/phpunit" ]; then
	cd $VAGRANT_ROOT/provisions
	sudo ./scripts/symlink-phpunit.sh $SERVER_ROOT
fi

if [ -e "$VAGRANT_ROOT/provisions/config.sh" ]; then
	cd $VAGRANT_ROOT/provisions
	sudo ./config.sh
fi