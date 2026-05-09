# Étape 1: Build - Installation des dépendances
FROM node:20.18.1-alpine3.20 AS builder

WORKDIR /app

# Copier package.json
COPY package*.json ./

# Installer TOUTES les dépendances (dev + prod)
RUN npm ci

# Copier le code source
COPY . .

# Étape 2: Production - Image finale légère
FROM node:20.18.1-alpine3.20

# Créer utilisateur non-root
RUN addgroup -g 1001 nodejs && adduser -S -u 1001 nodejs

WORKDIR /app

# Copier package.json
COPY package*.json ./

# Installer UNIQUEMENT les dépendances de production
RUN npm ci --only=production && npm cache clean --force

# Copier le code depuis l'étape de build
COPY --from=builder --chown=nodejs:nodejs /app .

# Utiliser l'utilisateur non-root
USER nodejs

# Port
EXPOSE 5000

# Démarrer
CMD ["node", "app.js"]
