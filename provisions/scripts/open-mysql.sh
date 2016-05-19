#open mysql to outside connections
sudo sed -i '/^bind-address/d' /etc/mysql/my.cnf
sudo echo 'bind-address = 0.0.0.0' >> /etc/mysql/my.cnf
sudo service mysql restart

#create remote mysql user
mysql -u root -pvagrant <<EOF
USE mysql;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
