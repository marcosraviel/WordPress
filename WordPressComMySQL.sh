#!/bin/bash
sudo apt -y update
sudo apt -y install php-curl php-gd php-mbstring php-xml php-xmlrpc
sudo apt -y install mysql-server

sudo debconf-set-selections <<< 'mysql-server mysql-server/password wordpress'
sudo apt -y install apache2
sudo apt -y install php libapache2-mod-php php-mysql

sudo mysql <<EOF
CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY 'wordpress';
\q
EOF

cd /tmp
wget -c http://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo rsync -av wordpress/* /var/www/html/
sudo chmod -R 755 /var/www/html/
cd /var/www/html
sudo mv wp-config-sample.php wp-config.php
sudo sed -i 's/database_name_here/wordpress/g' wp-config.php
sudo sed -i 's/username_here/wordpress/g' wp-config.php
sudo sed -i 's/password_here/wordpress/g' wp-config.php
sudo systemctl restart apache2
sudo systemctl restart mysql
sudo rm -rf /var/www/html/index.html
sudo sed -i '/warn/a <Directory /var/www/html/>\n   AllowOverride All\n</Directory>' /etc/apache2/sites-available/000-default.conf 
sudo a2enmod rewrite
sudo syystemctl restart apache2
sudo touch /var/www/html/htaccess
sudo chown :www-data /var/www/html/.htaccess
sudo chmod 664 /var/www/html/.htaccess
sudo systemctl restart mysql
sudo systemctl restart apache2
sudo service apache2 restart
echo "Concluido"

