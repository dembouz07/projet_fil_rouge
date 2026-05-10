# 🎨 Portfolio Application - Docker Images

Application portfolio complète avec Express.js, React et MongoDB.

**Auteur** : dembouz7  
**Repository GitHub** : [projet_fil_rouge](https://github.com/dembouz7/projet_fil_rouge)

## 🚀 Démarrage Rapide

### Prérequis
- Docker et Docker Compose installés
- Ports 3000, 5000, 27017 disponibles

### Démarrer l'application

1. **Créer un fichier `docker-compose.yml`** :

```yaml
version: '3.8'

services:
  mongodb:
    image: mongo:7.0.15
    container_name: portfolio-mongodb
    restart: unless-stopped
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_DATABASE: portfolio
    volumes:
      - mongodb_data:/data/db
    networks:
      - portfolio-network

  backend:
    image: dembouz7/portfolio-backend:latest
    container_name: portfolio-backend
    restart: unless-stopped
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
    image: dembouz7/portfolio-frontend:latest
    container_name: portfolio-frontend
    restart: unless-stopped
    ports:
      - "3000:80"
    depends_on:
      - backend
    networks:
      - portfolio-network

networks:
  portfolio-network:
    driver: bridge

volumes:
  mongodb_data:
    driver: local
```

2. **Démarrer les services** :
```bash
docker-compose up -d
```

3. **Seed de la base de données** :
```bash
docker exec -it portfolio-backend npm run seed
```

4. **Accéder à l'application** :
- Frontend : http://localhost:3000
- Backend API : http://localhost:5000

## 📦 Images Disponibles

### Backend (Express.js + MongoDB)
```bash
docker pull dembouz7/portfolio-backend:latest
docker pull dembouz7/portfolio-backend:1.0.0
```

**Caractéristiques :**
- Node.js 20.18.1 Alpine 3.20
- Express.js 4.18.2
- Mongoose 6.12.0
- Utilisateur non-root (nodejs, UID 1001)
- Multi-stage build
- Taille : ~150 MB

**Variables d'environnement :**
- `NODE_ENV` : production
- `PORT` : 5000
- `MONGODB_URI` : mongodb://mongodb:27017/portfolio

### Frontend (React + Nginx)
```bash
docker pull dembouz7/portfolio-frontend:latest
docker pull dembouz7/portfolio-frontend:1.0.0
```

**Caractéristiques :**
- Nginx 1.27.3 Alpine 3.20
- React 19.x
- Multi-stage build
- Utilisateur non-root (nginx-app, UID 1001)
- Taille : ~50 MB

## 🔒 Sécurité

- ✅ Utilisateurs non-root (UID 1001)
- ✅ Versions spécifiques et sécurisées :
  - node:20.18.1-alpine3.20
  - nginx:1.27.3-alpine3.20
  - mongo:7.0.15
- ✅ Images Alpine (légères et sécurisées)
- ✅ Multi-stage build
- ✅ Conformité OWASP et CIS Benchmark

## 🛠️ Commandes Utiles

### Voir les logs
```bash
docker-compose logs -f
```

### Arrêter les services
```bash
docker-compose down
```

### Redémarrer
```bash
docker-compose restart
```

### Accéder au backend
```bash
docker exec -it portfolio-backend sh
```

## 📚 Documentation

- GitHub : https://github.com/dembouz7/projet_fil_rouge
- Docker Hub : https://hub.docker.com/u/dembouz7

## 📝 Licence

MIT

## 👤 Auteur

Dembouz7
