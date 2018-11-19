#!/usr/bin/env bash

echo "1. Instalando Apache e PHP"
{
  sudo apt-get update 
  sudo apt-get install -y apache2 php5 git wget unzip
  sudo apt-get install -y php5-mysqlnd php5-curl php5-gd php5-intl php-pear php5-imap php5-mcrypt php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php-soap

  php5enmod mcrypt

  rm -rf /var/www/
  mkdir /vagrant/httpdocs
  ln -fs /vagrant/httpdocs /var/www/

  # Composer
  curl -sS https://getcomposer.org/installer | php  
  sudo mv composer.phar /usr/local/bin/composer  

} &> /dev/null

## Config vHost
echo "\n2. Configurando o vHost"
{
  VHOST=$(cat <<EOF
NameVirtualHost *:8080
Listen 8080
<VirtualHost *:80>
  DocumentRoot "/var/www/"
  ServerName localhost
  <Directory "/var/www/">
    AllowOverride All
  </Directory>
</VirtualHost>
<VirtualHost *:8080>
  DocumentRoot "/var/www/"
  ServerName localhost
  <Directory "/var/www/">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)


  echo "$VHOST" > /etc/apache2/sites-enabled/000-default.conf
  echo "ServerName localhost" | sudo tee /etc/apache2/conf.d/fqdn
  a2enmod rewrite
  service apache2 restart

} &> /dev/null


# Mysql
# --------------------
# Ignore the post install questions

echo "\n3. Instalando MySQL e phpMyAdmin"
{

  export DEBIAN_FRONTEND=noninteractive
# Install MySQL quietly
  apt-get -q -y install mysql-server phpmyadmin

    # Set root password for mysql
  debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
  debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
  # Set phpmyadmin paramaters for install
  debconf-set-selections <<< 'phpmyadmin phpmyadmin/debconfig-install boolean true'
  debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-user string root'
  debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password root'
  debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password root'
  debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password root'
  debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-websever multiselect none'
  debconf-set-selections <<< 'phpmyadmin phpmyadmin/database-type select mysql'
  debconf-set-selections <<< 'phpmyadmin phpmyadmin/setup-password password root'

  mysql -u root -e "CREATE DATABASE IF NOT EXISTS magento"
  mysql -u root -e "GRANT ALL PRIVILEGES ON magento.* TO 'root'@'localhost' IDENTIFIED BY 'root'"
  mysql -u root -e "FLUSH PRIVILEGES"

  sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
  sudo ln -s /usr/share/phpmyadmin /var/www/phpmyadmin
  sudo service apache2 restart

} &> /dev/null

echo "\n4. Instalando Magento (com tradução PT-BR)"
{
  cd /var/www/
  git clone https://github.com/OpenMage/magento-mirror.git ./ 
  wget https://raw.githubusercontent.com/Vinai/compressed-magento-sample-data/1.9.1.0/compressed-magento-sample-data-1.9.1.0.tgz 

  tar -xf compressed-magento-sample-data-1.9.1.0.tgz 
  cp -rv magento-sample-data-1.9.1.0/* ./  
  rm -rf magento-sample-data-1.9.1.0/ 

  mysql -u root magento < magento_sample_data_for_1.9.1.0.sql

## Translate pt_BR

  wget http://mariosam.com.br/wp-content/uploads/2013/02/Traducao_Magento_ptBR_19xx_MarioSAM_v12.zip 
  unzip Traducao_Magento_ptBR_19xx_MarioSAM_v12.zip 

  cp -rv Traducao_Magento_ptBR_19xx_MarioSAM/pt_BR app/locale/ 
  cp -rv Traducao_Magento_ptBR_19xx_MarioSAM/rwd/ app/design/frontend/ 
  rm -rf Traducao_Magento_ptBR_19xx_MarioSAM Traducao_Magento_ptBR_19xx_MarioSAM_v12.zip 

} &> /dev/null

## Install PayPal (Brazilian module)
echo "\n5. Instalando módulo PayPal Brasil ( ͡° ͜ʖ ͡°)"
{
  git clone https://github.com/br-paypaldev/magento-module.git paypal
  cp -rv paypal/app ./
  cp -rv paypal/js ./
  cp -rv paypal/lib ./
  cp -rv paypal/skin ./
  rm -rf paypal/

} &> /dev/null

echo "\n6. Finalizando..."
{
  chmod -R o+w media var 
  chmod o+w app/etc 
  find . -type d -exec chmod 775 '{}' \;
  find . -type f -exec chmod 644 '{}' \;
  chmod -Rv 777 app/etc var/ media/

} &> /dev/null
 
echo "\n7. Pronto!\n\n"