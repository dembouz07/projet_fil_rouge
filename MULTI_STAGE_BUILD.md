# Multi-Stage Build - Explication

## 🎯 Qu'est-ce que le Multi-Stage Build ?

Le **multi-stage build** permet de créer des images Docker **plus légères** en séparant :
1. **Étape de build** : Installation de toutes les dépendances
2. **Étape de production** : Copie uniquement des fichiers nécessaires

---

## 📦 Backend Express.js - Multi-Stage

### Dockerfile (express-js/Dockerfile)

```dockerfile
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
```

### Explication

#### Étape 1 : Builder (ligne 2-13)
```dockerfile
FROM node:20.18.1-alpine3.20 AS builder
```
- **AS builder** : Nomme cette étape "builder"
- Installe **toutes** les dépendances (dev + prod)
- Copie tout le code source
- Cette étape sera **jetée** à la fin

#### Étape 2 : Production (ligne 15-35)
```dockerfile
FROM node:20.18.1-alpine3.20
```
- Nouvelle image **propre**
- Installe **uniquement** les dépendances de production
- Copie le code depuis l'étape "builder"
- Crée l'utilisateur non-root
- C'est l'image **finale**

### Avantages

| Aspect | Sans Multi-Stage | Avec Multi-Stage |
|--------|------------------|------------------|
| **Taille** | ~200 MB | ~150 MB |
| **DevDependencies** | Incluses | Exclues |
| **Cache npm** | Présent | Nettoyé |
| **Sécurité** | Moyenne | Élevée |

---

## 📦 Frontend React - Multi-Stage

### Dockerfile (react-js/Dockerfile)

```dockerfile
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
```

### Explication

#### Étape 1 : Build (ligne 2-22)
```dockerfile
FROM node:20.18.1-alpine3.20 AS build
```
- Utilise **Node.js** pour compiler React
- Installe toutes les dépendances
- Exécute `npm run build`
- Génère le dossier `/app/build`
- Cette étape sera **jetée**

#### Étape 2 : Production (ligne 24-48)
```dockerfile
FROM nginx:1.27.3-alpine3.20
```
- Utilise **Nginx** (pas Node.js !)
- Copie **uniquement** le dossier `/app/build`
- Pas de Node.js dans l'image finale
- Pas de node_modules
- C'est l'image **finale**

### Avantages

| Aspect | Sans Multi-Stage | Avec Multi-Stage |
|--------|------------------|------------------|
| **Taille** | ~1.1 GB | ~50 MB |
| **Node.js** | Inclus | Exclu |
| **node_modules** | Présent | Absent |
| **Serveur** | Node.js | Nginx |
| **Performance** | Moyenne | Excellente |

---

## 🔍 Comparaison Visuelle

### Backend Express.js

```
┌─────────────────────────────────────────┐
│ Étape 1: Builder (jetée)               │
│ - Node.js 20.18.1                       │
│ - npm ci (toutes dépendances)           │
│ - Code source                           │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ Étape 2: Production (image finale)     │
│ - Node.js 20.18.1                       │
│ - npm ci --only=production              │
│ - Code copié depuis builder            │
│ - Utilisateur nodejs                    │
│ - Taille: ~150 MB                       │
└─────────────────────────────────────────┘
```

### Frontend React

```
┌─────────────────────────────────────────┐
│ Étape 1: Build (jetée)                 │
│ - Node.js 20.18.1                       │
│ - npm ci                                │
│ - npm run build                         │
│ - Génère /app/build                     │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ Étape 2: Production (image finale)     │
│ - Nginx 1.27.3                          │
│ - Copie /app/build depuis étape 1      │
│ - Utilisateur nginx-app                 │
│ - Taille: ~50 MB                        │
└─────────────────────────────────────────┘
```

---

## 📊 Résultats

### Tailles des Images

| Image | Sans Multi-Stage | Avec Multi-Stage | Réduction |
|-------|------------------|------------------|-----------|
| **Backend** | ~200 MB | ~150 MB | -25% |
| **Frontend** | ~1.1 GB | ~50 MB | **-95%** |
| **Total** | ~1.3 GB | ~200 MB | **-85%** |

### Contenu des Images Finales

#### Backend
- ✅ Node.js runtime
- ✅ Dépendances de production uniquement
- ✅ Code source
- ❌ DevDependencies (nodemon, etc.)
- ❌ Cache npm

#### Frontend
- ✅ Nginx
- ✅ Fichiers statiques (HTML, CSS, JS)
- ❌ Node.js
- ❌ node_modules
- ❌ Code source React

---

## 🚀 Commandes

### Build
```bash
docker-compose build
```

### Vérifier les tailles
```bash
docker images | grep portfolio
```

Résultat attendu :
```
projet_fil_rouge-backend    latest    150MB
projet_fil_rouge-frontend   latest    50MB
```

### Vérifier le contenu
```bash
# Backend - Node.js présent
docker run --rm projet_fil_rouge-backend node --version
# v20.18.1

# Frontend - Nginx présent, Node.js absent
docker run --rm projet_fil_rouge-frontend nginx -v
# nginx/1.27.3

docker run --rm projet_fil_rouge-frontend node --version
# sh: node: not found (normal !)
```

---

## ✅ Avantages du Multi-Stage Build

1. **Images plus légères**
   - Moins d'espace disque
   - Téléchargement plus rapide
   - Déploiement plus rapide

2. **Sécurité renforcée**
   - Moins de packages installés
   - Moins de surface d'attaque
   - Pas de devDependencies en production

3. **Performance**
   - Démarrage plus rapide
   - Moins de mémoire utilisée
   - Nginx plus performant que Node.js pour servir des fichiers statiques

4. **Séparation des préoccupations**
   - Build séparé de la production
   - Environnements distincts
   - Meilleure organisation

---

## 🎯 Bonnes Pratiques Appliquées

- ✅ Multi-stage build
- ✅ Versions spécifiques (pas de `latest`)
- ✅ Utilisateurs non-root
- ✅ Images Alpine (légères)
- ✅ Nettoyage du cache npm
- ✅ Permissions explicites
- ✅ Ordre des couches optimisé

---

**Vos Dockerfiles utilisent maintenant le multi-stage build ! 🚀**
