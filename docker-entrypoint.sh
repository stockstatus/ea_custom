#!/bin/sh
# Fixes Apache MPM conflict at runtime — base image entrypoint may re-enable mpm_event
find /etc/apache2/mods-enabled/ -name "mpm_*" -delete
ln -sf /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load
ln -sf /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf
exec "$@"
