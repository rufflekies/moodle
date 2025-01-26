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
DB_NAME=${DB_NAME:-moodle} # Default to 'moodle' if no input

read -p "Database User (default: admin): " DB_USER
DB_USER=${DB_USER:-admin} # Default to 'admin' if no input

read -sp "Database Password (default: admin): " DB_PASSWORD
DB_PASSWORD=${DB_PASSWORD:-admin} # Default to 'admin' if no input
echo "" # Add a newline after password input

echo_green "-----------------------------------------------"
echo_green "Database Configuration:"
echo_white "Database Name: $DB_NAME"
echo_white "Database User: $DB_USER"
echo_white "Database Password: $DB_PASSWORD"
echo_green "-----------------------------------------------"

# Step 2: Update system packages
echo_green "Step 2: Updating system packages..."
apt update && apt upgrade -y

# Step 3: Install required dependencies
echo_green "Step 3: Installing dependencies for Apache, PHP, and MariaDB..."
apt install apache2 libapache2-mod-php php-mysql php-mbstring php-curl php-tokenizer php-xmlrpc php-soap php-zip php-gd php-xml php-intl mariadb-server -y

# Step 4: Update PHP configuration
echo_green "Step 4: Updating PHP configuration to increase max_input_vars..."
echo "max_input_vars = 5000" >> /etc/php/8.1/apache2/php.ini

# Step 5: Restart Apache to apply PHP changes
echo_green "Step 5: Restarting Apache to apply PHP configuration changes..."
systemctl restart apache2

# Step 6: Configure MariaDB database
echo_green "Step 6: Setting up MariaDB for Moodle database..."
mysql -e "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "FLUSH PRIVILEGES;"

# Step 7: Check and download Moodle if not already downloaded
MOODLE_ARCHIVE="moodle.tgz"
MOODLE_URL="https://download.moodle.org/download.php/direct/stable403/moodle-latest-403.tgz"

echo_green "Step 7: Checking if Moodle archive already exists..."
if [ -f "$MOODLE_ARCHIVE" ]; then
    echo_green "Moodle archive already exists. Skipping download."
else
    echo_green "Downloading Moodle..."
    wget "$MOODLE_URL" -O "$MOODLE_ARCHIVE"
fi

# Extract Moodle
echo_green "Extracting Moodle..."
tar xzvf "$MOODLE_ARCHIVE"
mv moodle /var/www/moodle
mkdir /var/www/moodledata

# Step 8: Set appropriate file permissions
echo_green "Step 8: Setting file permissions for Moodle..."
chown -R www-data:www-data /var/www/moodle /var/www/moodledata
chmod -R 755 /var/www/moodle /var/www/moodledata

# Step 9: Configure Apache Virtual Host for Moodle
echo_green "Step 9: Configuring Apache Virtual Host for Moodle..."
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

# Step 10: Enable site and restart Apache
echo_green "Step 10: Enabling the Moodle site and restarting Apache..."
a2enmod rewrite
a2ensite moodle
systemctl restart apache2

# Step 11: Configure UFW (Uncomplicated Firewall) for HTTP and HTTPS
echo_green "Step 11: Configuring UFW firewall for HTTP and HTTPS..."
ufw allow http
ufw allow https

# Final Step: Installation complete with database details and IP address
echo_green "Step 12: Moodle installation complete."
echo_green "-----------------------------------------------"
echo_green "Database Name: "; echo_white "$DB_NAME"
echo_green "User: "; echo_white "$DB_USER"
echo_green "Password: "; echo_white "$DB_PASSWORD"
echo_green "IP Address: "; echo_white "$SERVER_IP"
echo_green "-----------------------------------------------"
