
# just some occasional bs
# enable short_open_tags
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php5/apache2/php.ini

# bump execution time
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php5/apache2/php.ini

# bump ram
sudo sed -i 's/memory_limit = 128M/memory_limit = 256M/g' /etc/php5/apache2/php.ini

