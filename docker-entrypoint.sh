#!/bin/sh
# Fix MPM conflict
find /etc/apache2/mods-enabled/ -name "mpm_*" -delete
ln -sf /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load
ln -sf /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf

# Debug: find EA entrypoint / config setup scripts
echo "=== Searching for entrypoint scripts ==="
find / -maxdepth 4 -name "entrypoint*" -o -name "start*.sh" -o -name "docker*.sh" 2>/dev/null | grep -v proc
echo "=== /var/www/html contents ==="
ls /var/www/html/
echo "=== config files ==="
ls /var/www/html/config* 2>/dev/null || echo "(no config files)"

exec apache2-foreground
