#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "I need more power (try again with sudo)"
  exit 1
fi

read -p "Upgrade packages too? (Yy|Nn): " upg
upgrade=${upg^^}

sudo apt update -y

if [[ $upgrade == "Y" ]]
then
  sudo apt upgrade -y
fi

# Apache setup
sudo apt install apache2 apache2-utils php -y
sudo systemctl enable apache2
sudo systemctl start apache2

# Set up web directory
read -p "What web directory to use [/var/www/html/]: " webdir
webdir=${name:-/var/www/html/}
sudo rm -rf "$webdir"
if [ ! -d "$DIRECTORY" ]; then
  mkdir "$webdir"
fi

# Get the latest wordpress code
rm /tmp/latest.tar.gz
rm -rf /tmp/wordpress
wget -O /tmp/latest.tar.gz http://wordpress.org/latest.tar.gz
tar -xzvf /tmp/latest.tar.gz -C /tmp/
mv /tmp/wordpress/* "$webdir"
sudo chown -R www-data:www-data "$webdir"
sudo chmod -R 755 "$webdir"

# Database setup
sudo apt install mysql-client mysql-server -y
read -p "\nName of WP database to make: " dbname
read -p "\nWordpress User to make: " username
read -s -p "\nWordpress User's Password: " password
echo
echo "CREATE DATABASE $dbname;" > /tmp/scheme.sql
echo "GRANT ALL PRIVLEGES ON $dbname.* TO '$username'@'localhost' IDENTIFIED BY '$password';" >> /tmp/scheme.sql
echo "FLUSH PRIVILEGES;" >> /tmp/scheme.sql
echo "EXIT;" >> /tmp/scheme.sql
echo "Attempting to log in as root and apply settings..."
mysql --user=root --password -s < /tmp/scheme.sql
echo "Deleting that config file for security"
rm /tmp/scheme.sql

# Set the wordpress config
sudo mv $webdir"wp-config-sample.php" $webdir"wp-config.php"
sed -i "s/database_name_here/$dbname/g" $webdir"wp-config.php"
sed -i "s/username_here/$username/g" $webdir"wp-config.php"
sed -i "s/password_here/$password/g" $webdir"wp-config.php"

sudo systemctl restart apache2.service 
sudo systemctl restart mysql.service

printf "\n\nDone. :)\n"
