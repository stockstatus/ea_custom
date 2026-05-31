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
# Kopíruj z assets/css/css/ priamo do assets/css/ — opravuje dvojité vnorenie
COPY assets/css/css ./assets/css

# Skompiluj SCSS → CSS
RUN npx gulp styles

# ═══════════════════════════════════════════════════════════

# Stage 2: Produkčný image
FROM alextselegidis/easyappointments:latest

# Nahraď skompilované CSS súbory custom verziou
COPY --from=css-builder /build/assets/css /var/www/html/assets/css

# Custom hlavička (salon názov namiesto EA brandingu)
COPY application/views/components/backend_header.php /var/www/html/application/views/components/backend_header.php

# Runtime fix: entrypoint wrapper odstraňuje MPM konflikt pred štartom Apache
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
