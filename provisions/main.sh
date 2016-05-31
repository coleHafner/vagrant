#friendly up passed vars
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

# install curl
sudo apt-get install -y curl

#install server utils
sudo apt-get install -y vim
sudo apt-get install -y htop

# install latest version of git
sudo apt-add-repository -y ppa:git-core/ppa
sudo apt-get -y update
sudo apt-get -y install git

# install node.js
curl -sL https://deb.nodesource.com/setup | sudo bash -
sudo apt-get -y install nodejs

# install latest npm
sudo npm -g install npm@latest

# install grunty-mc-grunt-face
sudo npm install -g grunt-cli

#disable stupid progress bar
sudo npm config set progress false --global

#npm install
cd $DOC_ROOT && npm install

if [ -e "$VAGRANT_ROOT/provisions/config.sh" ]; then
	cd $VAGRANT_ROOT/provisions
	sudo ./config.sh
fi
