# ═══════════════════════════════════════════════════════════
# Masáže Karin — Custom EasyAppointments Image
# CSS je pre-skompilované lokálne, žiadna gulp kompilácia
# ═══════════════════════════════════════════════════════════

FROM alextselegidis/easyappointments:latest

# Nahraď CSS custom verziou (pre-skompilované)
COPY assets/css /var/www/html/assets/css

# Custom hlavička (salon názov namiesto EA brandingu)
COPY application/views/components/backend_header.php /var/www/html/application/views/components/backend_header.php

# Runtime fix: entrypoint wrapper
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
