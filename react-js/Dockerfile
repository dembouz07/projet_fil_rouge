# Étape 1: Build avec Node.js
FROM node:20.18.1-alpine3.20 AS build

# Installer les dépendances système nécessaires
RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copier uniquement les fichiers de dépendances d'abord (pour le cache)
COPY package*.json ./

# Installer les dépendances (cette layer sera cachée si package.json ne change pas)
RUN npm ci --prefer-offline --no-audit

# Copier le reste du code
COPY . .

# Build React avec optimisations
# NOTE: l'étape de build s'exécute en root (image jetable) pour éviter
# un "chown -R" coûteux sur node_modules qui surchargeait le démon Docker.
ENV NODE_ENV=production
ENV GENERATE_SOURCEMAP=false
# Limiter la mémoire de Node pour éviter l'OOM du moteur Docker (WSL2)
ENV NODE_OPTIONS=--max-old-space-size=2048
RUN npm run build

# Étape 2: Production avec Nginx (image finale légère)
FROM nginx:1.27.3-alpine3.20

# Créer utilisateur pour Nginx
RUN addgroup -g 1001 nginx-app && adduser -S -u 1001 nginx-app

# Copier uniquement le build (pas les node_modules ni le code source)
COPY --from=build --chown=nginx-app:nginx-app /app/build /usr/share/nginx/html

# Copier la config Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Donner les permissions à nginx-app
RUN chown -R nginx-app:nginx-app /var/cache/nginx && \
    chown -R nginx-app:nginx-app /var/log/nginx && \
    chown -R nginx-app:nginx-app /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx-app:nginx-app /var/run/nginx.pid

# Utiliser l'utilisateur non-root
USER nginx-app

EXPOSE 80

# Healthcheck pour vérifier que Nginx fonctionne
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
