#!/bin/bash

# Define colors
green="\033[0;32m"
white="\033[0;37m"
reset="\033[0m"

# Function to echo in green
echo_green() {
    echo -e "${green}$1${reset}"
}

# Function to echo in white
echo_white() {
    echo -e "${white}$1${reset}"
}

# Get the primary IP address of the server
SERVER_IP=$(hostname -I | awk '{print $1}')

# Step 1: Ask for database configuration
echo_green "Step 1: Enter the database details for Moodle."
echo_green "-----------------------------------------------"
read -p "Database Name (default: moodle): " DB_NAME
DB_NAME=${DB_NAME:-moodle}

read -p "Database User (default: admin): " DB_USER
DB_USER=${DB_USER:-admin}

read -sp "Database Password (default: admin): " DB_PASSWORD
DB_PASSWORD=${DB_PASSWORD:-admin}
echo ""

echo_green "-----------------------------------------------"
echo_green "Database Configuration:"
echo_white "Database Name: $DB_NAME"
echo_white "Database User: $DB_USER"
echo_white "Database Password: $DB_PASSWORD"
echo_green "-----------------------------------------------"

# Step 2: Update system packages
echo_green "Step 2: Updating system packages..."
apt update && apt upgrade -y

# Step 3: Install required tools and add PHP 8.1 repository
echo_green "Step 3: Installing software-properties-common and PHP 8.1 repository..."
apt install software-properties-common -y
add-apt-repository ppa:ondrej/php -y
apt update

# Step 4: Install PHP 8.1 and required modules
echo_green "Step 4: Installing PHP 8.1 and required extensions..."
apt install apache2 mariadb-server -y
apt install php8.1 php8.1-mysql php8.1-mbstring php8.1-curl php8.1-tokenizer php8.1-xmlrpc php8.1-soap php8.1-zip php8.1-gd php8.1-xml php8.1-intl libapache2-mod-php8.1 -y

# Step 5: Set PHP 8.1 as default
echo_green "Step 5: Setting PHP 8.1 as default..."
update-alternatives --set php /usr/bin/php8.1
a2dismod php8.3 >/dev/null 2>&1
a2enmod php8.1
systemctl restart apache2

# Step 6: Update PHP configuration
echo_green "Step 6: Updating PHP configuration to increase max_input_vars..."
echo "max_input_vars = 5000" >> /etc/php/8.1/apache2/php.ini
systemctl restart apache2

# Step 7: Setup MariaDB database
echo_green "Step 7: Setting up MariaDB for Moodle..."
mysql -e "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "FLUSH PRIVILEGES;"

# Step 8: Download Moodle
MOODLE_ARCHIVE="moodle.tgz"
MOODLE_URL="https://download.moodle.org/download.php/direct/stable403/moodle-latest-403.tgz"

echo_green "Step 8: Checking if Moodle archive already exists..."
if [ -f "$MOODLE_ARCHIVE" ]; then
    echo_green "Moodle archive already exists. Skipping download."
else
    echo_green "Downloading Moodle..."
    wget "$MOODLE_URL" -O "$MOODLE_ARCHIVE"
fi

# Step 9: Extract Moodle
echo_green "Step 9: Extracting Moodle..."
tar xzvf "$MOODLE_ARCHIVE"
mv moodle /var/www/moodle
mkdir /var/www/moodledata

# Step 10: Set permissions
echo_green "Step 10: Setting file permissions for Moodle..."
chown -R www-data:www-data /var/www/moodle /var/www/moodledata
chmod -R 755 /var/www/moodle /var/www/moodledata

# Step 11: Apache virtual host
echo_green "Step 11: Configuring Apache Virtual Host for Moodle..."
cat <<EOL > /etc/apache2/sites-available/moodle.conf
<VirtualHost *:80>
    ServerName $SERVER_IP
    DocumentRoot /var/www/moodle
    <Directory /var/www/moodle>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/apache2/moodle_error.log
    CustomLog /var/log/apache2/moodle_access.log combined
</VirtualHost>
EOL

# Step 12: Enable site and restart Apache
echo_green "Step 12: Enabling the Moodle site and restarting Apache..."
a2enmod rewrite
a2ensite 000-default.conf
a2ensite moodle.conf
systemctl reload apache2

# Step 13: Configure UFW
echo_green "Step 13: Configuring UFW firewall for HTTP and HTTPS..."
ufw allow http
ufw allow https

# Final Step
echo_green "Step 14: Moodle installation complete."
echo_green "-----------------------------------------------"
echo_green "Database Name: "; echo_white "$DB_NAME"
echo_green "User: "; echo_white "$DB_USER"
echo_green "Password: "; echo_white "$DB_PASSWORD"
echo_green "IP Address: "; echo_white "$SERVER_IP"
echo_green "Access Moodle at: http://$SERVER_IP"
echo_green "-----------------------------------------------"
