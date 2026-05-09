# Étape 1: Build avec Node.js
FROM node:20.18.1-alpine3.20 AS build

# Créer utilisateur pour le build
RUN addgroup -g 1001 nodejs && adduser -S -u 1001 nodejs

WORKDIR /app

# Copier et installer en tant que root
COPY package*.json ./
RUN npm ci

# Copier le code
COPY . .

# Créer le dossier build et donner les permissions
RUN mkdir -p build && chown -R nodejs:nodejs /app

# Passer à l'utilisateur non-root
USER nodejs

# Build React
RUN npm run build

# Étape 2: Production avec Nginx
FROM nginx:1.27.3-alpine3.20

# Créer utilisateur pour Nginx
RUN addgroup -g 1001 nginx-app && adduser -S -u 1001 nginx-app

# Copier le build
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
CMD ["nginx", "-g", "daemon off;"]
