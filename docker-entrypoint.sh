#!/bin/sh
# Fix MPM conflict, then hand off to original EA entrypoint (creates config.php from env vars)
find /etc/apache2/mods-enabled/ -name "mpm_*" -delete
ln -sf /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load
ln -sf /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf
exec /entrypoint.sh "$@"
