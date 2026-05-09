# Portfolio Application - Docker Images

Application portfolio complète avec Express.js, React et MongoDB.

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
    image: VOTRE_USERNAME/portfolio-backend:latest
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
    image: VOTRE_USERNAME/portfolio-frontend:latest
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
docker pull VOTRE_USERNAME/portfolio-backend:latest
docker pull VOTRE_USERNAME/portfolio-backend:1.0.0
```

**Caractéristiques :**
- Node.js 20.18.1 Alpine
- Express.js 4.18.2
- Mongoose 6.12.0
- Utilisateur non-root (nodejs)
- Taille : ~150 MB

**Variables d'environnement :**
- `NODE_ENV` : production
- `PORT` : 5000
- `MONGODB_URI` : mongodb://mongodb:27017/portfolio

### Frontend (React + Nginx)
```bash
docker pull VOTRE_USERNAME/portfolio-frontend:latest
docker pull VOTRE_USERNAME/portfolio-frontend:1.0.0
```

**Caractéristiques :**
- Nginx 1.27.3 Alpine
- React 18.x
- Multi-stage build
- Utilisateur non-root (nginx-app)
- Taille : ~50 MB

## 🔒 Sécurité

- ✅ Utilisateurs non-root
- ✅ Versions spécifiques (pas de `latest`)
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

- GitHub : [Lien vers votre repo]
- Documentation complète : [Lien]

## 📝 Licence

MIT

## 👤 Auteur

Votre Nom
