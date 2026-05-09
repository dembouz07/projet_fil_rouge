# Image Node.js Alpine
FROM node:20-alpine

# Créer utilisateur non-root
RUN addgroup -g 1001 nodejs && adduser -S -u 1001 nodejs

# Dossier de travail
WORKDIR /app

# Copier package.json
COPY package*.json ./

# Installer les dépendances
RUN npm ci --only=production

# Copier le code avec les bonnes permissions
COPY --chown=nodejs:nodejs . .

# Utiliser l'utilisateur non-root
USER nodejs

# Port
EXPOSE 5000

# Démarrer
CMD ["node", "app.js"]
