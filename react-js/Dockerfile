# Étape 1: Build avec Node.js
FROM node:20-alpine AS build

# Créer utilisateur pour le build
RUN addgroup -g 1001 nodejs && adduser -S -u 1001 nodejs

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY --chown=nodejs:nodejs . .

USER nodejs
RUN npm run build

# Étape 2: Production avec Nginx
FROM nginx:alpine

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
