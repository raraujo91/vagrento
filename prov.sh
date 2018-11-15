#!/usr/bin/env bash

echo ">>> Iniciando a instalação..."

# Update
sudo apt-get update &> /dev/null

# Install MySQL without prompt
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root' &> /dev/null
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root' &> /dev/null

# Install base items
sudo apt-get install -y vim curl wget build-essential python-software-properties &> /dev/null

echo ">>> Instalando PHP e componentes..."

# Add repo for latest PHP
sudo add-apt-repository -y ppa:ondrej/php5 &> /dev/null

# Update Again
sudo apt-get update &> /dev/null

# Install the Rest
sudo apt-get install -y git-core php5 apache2 libapache2-mod-php5 php5-mysql php5-curl php5-gd php5-mcrypt php5-xdebug mysql-server &> /dev/null

# Display php version
echo "\n\n"
php -v 
echo "\n\n"

# Sets localhost as ServerName
echo "ServerName localhost" | sudo tee /etc/apache2/conf.d/fqdn &> /dev/null 

echo ">>> Configurando o servidor..."

# xdebug Config
cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini 
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

# Apache Config
sudo a2enmod rewrite &> /dev/null 
curl https://gist.github.com/fideloper/2710970/raw/5d7efd74628a1e3261707056604c99d7747fe37d/vhost.sh > vhost &> /dev/null 
sudo chmod guo+x vhost &> /dev/null 
sudo mv vhost /usr/local/bin &> /dev/null 

# PHP Config
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini &> /dev/null 
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini &> /dev/null 

# Install phpMyAdmin
sudo apt-get install phpmyadmin apache2-utils &> /dev/null 
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf &> /dev/null  
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin &> /dev/null 

sudo service apache2 restart 

echo ">>> Instalando Composer..."

# Composer
curl -sS https://getcomposer.org/installer | php &> /dev/null 
sudo mv composer.phar /usr/local/bin/composer &> /dev/null 
