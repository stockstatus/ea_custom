#!/bin/sh
set -e

# Fix MPM conflict
find /etc/apache2/mods-enabled/ -name "mpm_*" -delete
ln -sf /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load
ln -sf /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf

# Create config.php from config-sample.php + environment variables
CONFIG=/var/www/html/config.php
SAMPLE=/var/www/html/config-sample.php

if [ ! -f "$CONFIG" ]; then
    echo "Creating config.php from environment variables..."
    cp "$SAMPLE" "$CONFIG"

    sed -i "s|define('DB_HOST', '.*')|define('DB_HOST', '${DB_HOST:-localhost}')|" "$CONFIG"
    sed -i "s|define('DB_NAME', '.*')|define('DB_NAME', '${DB_NAME:-easyappointments}')|" "$CONFIG"
    sed -i "s|define('DB_USERNAME', '.*')|define('DB_USERNAME', '${DB_USERNAME:-root}')|" "$CONFIG"
    sed -i "s|define('DB_PASSWORD', '.*')|define('DB_PASSWORD', '${DB_PASSWORD:-}')|" "$CONFIG"
    sed -i "s|define('DB_PORT', '.*')|define('DB_PORT', '${DB_PORT:-3306}')|" "$CONFIG"
    sed -i "s|define('APP_URL', '.*')|define('APP_URL', '${APP_URL:-http://localhost}')|" "$CONFIG"

    echo "config.php created."
    echo "=== DB settings in config.php ==="
    grep -E "DB_HOST|DB_NAME|DB_USERNAME|DB_PORT|APP_URL" "$CONFIG"
fi

# Stream Apache error log to stdout so Railway captures PHP errors
mkdir -p /var/log/apache2
touch /var/log/apache2/error.log
tail -f /var/log/apache2/error.log &

exec apache2-foreground
