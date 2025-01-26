#!/bin/bash

# Define green color variable
green="\033[0;32m"
reset="\033[0m"

# Function to echo in green
echo_green() {
    echo -e "${green}$1${reset}"
}

# Step 1: Ask for database details
echo_green "Step 1: Enter the database details to remove for Moodle."
echo_green "-----------------------------------------------"
read -p "Database Name (default: moodle): " DB_NAME
DB_NAME=${DB_NAME:-moodle}  # Default to 'moodle' if no input

read -p "Database User (default: admin): " DB_USER
DB_USER=${DB_USER:-admin}  # Default to 'admin' if no input

MoodleDir="/var/www/moodle"
MoodleDataDir="/var/www/moodledata"
ApacheConfFile="/etc/apache2/sites-available/moodle.conf"

# Step 2: Remove Moodle database and user
echo_green "Step 2: Deleting the Moodle database and user..."
mysql -e "DROP DATABASE IF EXISTS $DB_NAME;"
mysql -e "DELETE FROM mysql.user WHERE User='$DB_USER';"
mysql -e "FLUSH PRIVILEGES;"

# Step 3: Remove Moodle files
echo_green "Step 3: Deleting Moodle files from $MoodleDir..."
rm -rf $MoodleDir
rm -rf $MoodleDataDir

# Step 4: Remove Apache virtual host configuration
echo_green "Step 4: Removing Apache Virtual Host configuration..."
rm -f $ApacheConfFile

# Step 5: Disable and remove the Moodle site from Apache
echo_green "Step 5: Disabling Moodle site and restarting Apache..."
a2dissite moodle
systemctl restart apache2

# Step 6: Enable Apache default site
echo_green "Step 6: Re-enabling Apache default site (000-default.conf)..."
a2ensite 000-default.conf
systemctl restart apache2

# Final Step: Cleanup complete
echo_green "Moodle uninstallation and cleanup complete."
