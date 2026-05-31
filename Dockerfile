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

# Skompiluj SCSS → CSS (cache-bust: 2026-05-31)
RUN npx gulp styles

# Debug: overenie výstupu kompilácie (.css aj .min.css)
RUN echo "=== backend_layout.css ===" \
    && grep -c "k-bg" assets/css/layouts/backend_layout.css && echo "CSS OK" || echo "CHYBA: backend_layout.css bez k-bg" \
    && echo "=== backend_layout.min.css ===" \
    && grep -c "k-bg" assets/css/layouts/backend_layout.min.css && echo "MIN OK" || echo "CHYBA: min bez k-bg"

# ═══════════════════════════════════════════════════════════

# Stage 2: Produkčný image
FROM alextselegidis/easyappointments:latest

# Nahraď skompilované CSS súbory custom verziou
COPY --from=css-builder /build/assets/css /var/www/html/assets/css

# Priamo appendni dark téma do backend_layout.css (EA načítava .css nie .min.css)
RUN printf '\n:root{--k-bg:#2C1A0E;--k-bg-mid:#3d2510;--k-gold:#C9963C;--k-gold-pale:#F5E6C4;--k-text:#F5E6C4;--k-border:rgba(201,150,60,.25)}body{background-color:var(--k-bg)!important;color:var(--k-text)!important}main{background-color:var(--k-bg)}\n' \
    >> /var/www/html/assets/css/layouts/backend_layout.css

# Custom hlavička (salon názov namiesto EA brandingu)
COPY application/views/components/backend_header.php /var/www/html/application/views/components/backend_header.php

# Runtime fix: entrypoint wrapper odstraňuje MPM konflikt pred štartom Apache
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
