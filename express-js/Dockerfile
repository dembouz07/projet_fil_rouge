# Utiliser l'image Node.js officielle
FROM node:20-alpine

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances
RUN npm ci --only=production

# Copier le reste des fichiers
COPY . .

# Exposer le port 5000
EXPOSE 5000

# Définir les variables d'environnement par défaut
ENV NODE_ENV=production
ENV PORT=5000

# Commande pour démarrer l'application
CMD ["node", "app.js"]
