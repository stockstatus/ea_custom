# ═══════════════════════════════════════════════════════════
# Masáže Karin — Custom EasyAppointments Image
# Stage 1: Skompiluje SCSS (karin téma + backend layout)
# Stage 2: Skopíruje CSS do oficiálneho EA image
# ═══════════════════════════════════════════════════════════

# Stage 1: Build SCSS
FROM node:18-alpine AS css-builder

WORKDIR /build

# Nainštaluj závislosti (potrebné pre Bootstrap SCSS)
COPY package*.json ./
RUN npm ci

# Skopíruj len to čo treba na kompiláciu
COPY gulpfile.js ./
COPY assets/css ./assets/css

# Skompiluj SCSS → CSS
RUN npx gulp styles

# ═══════════════════════════════════════════════════════════

# Stage 2: Produkčný image
FROM alextselegidis/easyappointments:latest

# Debug: ukáž čo je v mods-enabled pred opravou (viditeľné v Railway build logu)
RUN echo "=== MPM files before fix ===" \
    && ls /etc/apache2/mods-enabled/ | grep mpm || echo "(žiadne mpm súbory)"

# Oprava: odober VŠETKY mpm_* súbory cez find, potom enable len prefork
RUN find /etc/apache2/mods-enabled/ -name "mpm_*" -delete \
    && ln -sf /etc/apache2/mods-available/mpm_prefork.load \
              /etc/apache2/mods-enabled/mpm_prefork.load \
    && ln -sf /etc/apache2/mods-available/mpm_prefork.conf \
              /etc/apache2/mods-enabled/mpm_prefork.conf \
    && echo "=== MPM files after fix ===" \
    && ls /etc/apache2/mods-enabled/ | grep mpm

# Nahraď skompilované CSS súbory custom verziou
COPY --from=css-builder /build/assets/css /var/www/html/assets/css

# Custom hlavička (salon názov namiesto EA brandingu)
COPY application/views/components/backend_header.php /var/www/html/application/views/components/backend_header.php
