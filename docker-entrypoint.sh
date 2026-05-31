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

    # EA v2+ uses "const KEY = 'value';" format
    sed -i "s|const DB_HOST = '.*'|const DB_HOST = '${DB_HOST:-localhost}'|" "$CONFIG"
    sed -i "s|const DB_NAME = '.*'|const DB_NAME = '${DB_NAME:-easyappointments}'|" "$CONFIG"
    sed -i "s|const DB_USERNAME = '.*'|const DB_USERNAME = '${DB_USERNAME:-root}'|" "$CONFIG"
    sed -i "s|const DB_PASSWORD = '.*'|const DB_PASSWORD = '${DB_PASSWORD:-}'|" "$CONFIG"
    sed -i "s|const DB_PORT = '.*'|const DB_PORT = '${DB_PORT:-3306}'|" "$CONFIG"
    sed -i "s|const APP_URL = '.*'|const APP_URL = '${APP_URL:-http://localhost}'|" "$CONFIG"

    echo "config.php created."
    echo "=== DB settings in config.php ==="
    grep -E "DB_HOST|DB_NAME|DB_USERNAME|DB_PORT|APP_URL" "$CONFIG"
fi

# Stream Apache error log to stdout
mkdir -p /var/log/apache2
touch /var/log/apache2/error.log
tail -f /var/log/apache2/error.log &

exec apache2-foreground
