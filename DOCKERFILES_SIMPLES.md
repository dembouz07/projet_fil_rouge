# Dockerfiles Simples avec Sécurité

## ✅ Caractéristiques

- **Simple** : Facile à comprendre
- **Sécurisé** : Utilisateurs non-root
- **Optimisé** : Images Alpine légères

---

## 📦 express-js/Dockerfile (17 lignes)

```dockerfile
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
```

**Explication ligne par ligne :**
1. `FROM node:20-alpine` : Image de base légère
2. `RUN addgroup...` : Créer un utilisateur `nodejs` (UID 1001)
3. `WORKDIR /app` : Dossier de travail
4. `COPY package*.json` : Copier les fichiers de dépendances
5. `RUN npm ci` : Installer les dépendances
6. `COPY --chown=nodejs:nodejs` : Copier le code avec les bonnes permissions
7. `USER nodejs` : **Passer en utilisateur non-root**
8. `EXPOSE 5000` : Exposer le port
9. `CMD ["node", "app.js"]` : Démarrer l'application

---

## 📦 react-js/Dockerfile (32 lignes)

```dockerfile
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
```

**Explication :**

### Étape 1 : Build
1. `FROM node:20-alpine AS build` : Image pour le build
2. `RUN addgroup...` : Créer utilisateur `nodejs`
3. `COPY package*.json` : Copier dépendances
4. `RUN npm ci` : Installer
5. `COPY --chown=nodejs:nodejs` : Copier le code
6. `USER nodejs` : **Passer en non-root**
7. `RUN npm run build` : Build React

### Étape 2 : Production
1. `FROM nginx:alpine` : Image Nginx légère
2. `RUN addgroup...` : Créer utilisateur `nginx-app`
3. `COPY --from=build` : Copier le build depuis l'étape 1
4. `COPY nginx.conf` : Copier la config
5. `RUN chown -R` : Donner les permissions Nginx
6. `USER nginx-app` : **Passer en non-root**
7. `CMD ["nginx"...]` : Démarrer Nginx

---

## 📦 docker-compose.yml (32 lignes)

```yaml
services:
  mongodb:
    image: mongo:7.0.15
    container_name: portfolio-mongodb
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
    networks:
      - portfolio-network
    user: "999:999"  # Utilisateur non-root

  backend:
    build: ./express-js
    container_name: portfolio-backend
    ports:
      - "5000:5000"
    environment:
      NODE_ENV: production
      PORT: 5000
      MONGODB_URI: mongodb://mongodb:27017/portfolio
    depends_on:
      - mongodb
    networks:
      - portfolio-network

  frontend:
    build: ./react-js
    container_name: portfolio-frontend
    ports:
      - "3000:80"
    depends_on:
      - backend
    networks:
      - portfolio-network

networks:
  portfolio-network:

volumes:
  mongodb_data:
```

**Explication :**
- `mongodb` : Image officielle avec utilisateur non-root (999:999)
- `backend` : Build depuis `./express-js/Dockerfile`
- `frontend` : Build depuis `./react-js/Dockerfile`
- `networks` : Réseau pour la communication entre services
- `volumes` : Persistance des données MongoDB

---

## 🔒 Sécurité

### Utilisateurs créés

| Service | Utilisateur | UID | Pourquoi |
|---------|-------------|-----|----------|
| Backend | `nodejs` | 1001 | Pas de privilèges root |
| Frontend | `nginx-app` | 1001 | Pas de privilèges root |
| MongoDB | `mongodb` | 999 | Utilisateur par défaut MongoDB |

### Vérification

```bash
# Backend
docker exec -it portfolio-backend whoami
# Résultat: nodejs

# Frontend
docker exec -it portfolio-frontend whoami
# Résultat: nginx-app

# MongoDB
docker exec -it portfolio-mongodb whoami
# Résultat: mongodb
```

---

## 🚀 Commandes

### Build et Démarrer
```bash
docker-compose up -d --build
```

### Vérifier
```bash
docker-compose ps
```

### Seed
```bash
docker exec -it portfolio-backend npm run seed
```

### Logs
```bash
docker-compose logs -f
```

### Arrêter
```bash
docker-compose down
```

---

## 📊 Tailles des Images

| Image | Taille | Commentaire |
|-------|--------|-------------|
| Backend | ~150 MB | Node.js Alpine + dépendances |
| Frontend | ~50 MB | Nginx Alpine + fichiers statiques |
| MongoDB | ~750 MB | Base de données complète |

---

## ✅ Avantages

1. **Simple** : Facile à lire et comprendre
2. **Sécurisé** : Utilisateurs non-root partout
3. **Léger** : Images Alpine
4. **Rapide** : Multi-stage build pour React
5. **Prêt pour production** : Bonnes pratiques appliquées

---

## 🎯 Différence avec version complexe

### Avant (complexe)
- 50+ lignes par Dockerfile
- Beaucoup de configurations
- Difficile à comprendre

### Après (simple)
- 17 lignes (Backend)
- 32 lignes (Frontend)
- Facile à comprendre
- **Toujours sécurisé !**

---

**C'est simple ET sécurisé ! 🔒✅**
