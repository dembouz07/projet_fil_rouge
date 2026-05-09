# PORTFOLIO - PROJET FIL ROUGE

Application complète de gestion de portfolio avec React (frontend), Express.js (backend) et MongoDB (base de données).

---

## Architecture

```
┌─────────────────┐      HTTP/REST      ┌──────────────────┐      Mongoose      ┌──────────────┐
│   REACT         │ ──────────────────> │  EXPRESS.JS      │ ─────────────────> │   MONGODB    │
│   Frontend      │ <────────────────── │  Backend API     │ <───────────────── │   Atlas      │
│   Port 3000     │      JSON           │  Port 5000       │      Documents     │   Cloud      │
└─────────────────┘                     └──────────────────┘                    └──────────────┘
```

---

## Technologies

### Frontend
- **React** 19.2.5
- **React Router** 7.14.1
- **Tailwind CSS**
- **Fetch API**

### Backend
- **Node.js** + **Express.js**
- **MongoDB** + **Mongoose**
- **express-validator** (validation)
- **CORS** (sécurité)
- **dotenv** (configuration)

### Base de données
- **MongoDB Atlas** (cloud)
- Cluster : `bdmongo.ref7efn.mongodb.net`
- Base : `portfolio`
- Collection : `projects`

---

## Structure du projet

```
projet_fil_rouge/
│
├── express-js/              # Backend API
│   ├── .env                 # Configuration (MongoDB, Port, CORS)
│   ├── app.js               # Point d'entrée
│   ├── package.json
│   ├── src/
│   │   ├── config/
│   │   │   └── database.js          # Connexion MongoDB
│   │   ├── models/
│   │   │   └── Project.js           # Schéma Mongoose
│   │   ├── controllers/
│   │   │   └── projectController.js # Logique métier (CRUD)
│   │   ├── routes/
│   │   │   └── projectRoutes.js     # Routes API
│   │   └── middleware/
│   │       ├── validators.js        # Validation des données
│   │       └── errorHandler.js      # Gestion des erreurs
│   └── README.md
│
├── react-js/                # Frontend
│   ├── src/
│   │   ├── components/      # Composants React
│   │   ├── pages/           # Pages
│   │   ├── services/
│   │   │   └── projectService.js  # Appels API
│   │   ├── hooks/
│   │   │   ├── useProjects.js     # Hook liste projets
│   │   │   └── useProject.js      # Hook projet unique
│   │   ├── App.jsx          # Routes
│   │   └── index.js
│   ├── package.json
│   └── README.md
│
└── Documentation/
    ├── README.md                      # Ce fichier
    ├── DEMARRAGE_RAPIDE.md            # Guide de démarrage
    ├── INTEGRATION_REACT_EXPRESS.md   # Documentation complète
    ├── EXPLICATION_CODE.md            # Code backend expliqué
    ├── MODIFICATIONS_REACT.md         # Changements React
    └── TESTS_INTEGRATION.md           # Guide de tests
```

---

## Démarrage rapide

### 1. Configuration MongoDB Atlas

1. Aller sur https://cloud.mongodb.com
2. Se connecter
3. **Network Access** → **Add IP Address** → **Allow Access from Anywhere** (0.0.0.0/0)
4. Attendre 1-2 minutes

### 2. Démarrer le Backend (Terminal 1)

```bash
cd express-js
npm install
npm run dev
```

**Vérification :**
```
✅ Serveur demarre sur le port 5000
✅ MongoDB connecte: bdmongo.ref7efn.mongodb.net
```

### 3. Démarrer le Frontend (Terminal 2)

```bash
cd react-js
npm install
npm start
```

**Vérification :**
- Navigateur s'ouvre sur http://localhost:3000
- Les projets s'affichent

---

## API Endpoints

| Méthode | URL | Description |
|---------|-----|-------------|
| GET | `/api/projects` | Liste tous les projets |
| GET | `/api/projects/:id` | Récupère un projet |
| POST | `/api/projects` | Crée un projet |
| PUT | `/api/projects/:id` | Met à jour un projet |
| DELETE | `/api/projects/:id` | Supprime un projet |

---

## Fonctionnalités

### Frontend (React)
- ✅ Lister tous les projets
- ✅ Voir les détails d'un projet
- ✅ Ajouter un nouveau projet
- ✅ Modifier un projet
- ✅ Supprimer un projet
- ✅ Responsive design
- ✅ Gestion des erreurs
- ✅ Loading states

### Backend (Express.js)
- ✅ API REST complète (CRUD)
- ✅ Validation des données (express-validator)
- ✅ Gestion des erreurs centralisée
- ✅ CORS configuré
- ✅ Connexion MongoDB Atlas
- ✅ Schéma Mongoose avec timestamps

### Base de données (MongoDB)
- ✅ MongoDB Atlas (cloud)
- ✅ Collection `projects`
- ✅ IDs uniques (`_id`)
- ✅ Timestamps automatiques (`createdAt`, `updatedAt`)

---

## Configuration

### Backend : `express-js/.env`

```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb+srv://ousseynoufayeisidk_db_user:ukhUdMTRhwYTOgeu@bdmongo.ref7efn.mongodb.net/portfolio?retryWrites=true&w=majority&appName=bdMongo
CORS_ORIGIN=http://localhost:3000
```

### Frontend : `react-js/src/services/projectService.js`

```javascript
const BASE_URL = 'http://localhost:5000/api/projects';
```

---

## Schéma de données

### Projet (MongoDB)

```javascript
{
  _id: ObjectId,              // ID MongoDB (auto-généré)
  title: String,              // Titre du projet (requis)
  description: String,        // Description (requis)
  technologies: [String],     // Technologies utilisées (requis)
  image: String,              // URL de l'image (optionnel)
  github: String,             // URL GitHub (optionnel)
  demo: String,               // URL démo (optionnel)
  createdAt: Date,            // Date de création (auto)
  updatedAt: Date             // Date de modification (auto)
}
```

---

## Tests

### Test manuel

1. **Backend** : http://localhost:5000
2. **Frontend** : http://localhost:3000
3. **Ajouter un projet** : Formulaire d'ajout
4. **Modifier** : Cliquer sur "Modifier"
5. **Supprimer** : Cliquer sur "Supprimer"

### Test avec Postman

```bash
# GET - Tous les projets
GET http://localhost:5000/api/projects

# POST - Créer un projet
POST http://localhost:5000/api/projects
Content-Type: application/json

{
  "title": "Test Projet",
  "description": "Description test",
  "technologies": ["React", "Node.js"],
  "image": "https://placehold.co/400x200",
  "github": "https://github.com/test",
  "demo": "https://demo.com"
}
```

Voir **TESTS_INTEGRATION.md** pour plus de détails.

---

## Dépannage

### Backend ne démarre pas
```bash
cd express-js
rm -rf node_modules
npm install
npm run dev
```

### MongoDB ne se connecte pas
1. Vérifier MongoDB Atlas → Network Access → IP autorisée
2. Vérifier `MONGODB_URI` dans `.env`
3. Redémarrer le backend

### CORS Error
1. Vérifier `CORS_ORIGIN=http://localhost:3000` dans `.env`
2. Redémarrer le backend

### Frontend ne charge pas les projets
1. Vérifier que le backend tourne sur port 5000
2. Ouvrir la console du navigateur (F12)
3. Vérifier les erreurs réseau

---

## Documentation

| Fichier | Description |
|---------|-------------|
| **DEMARRAGE_RAPIDE.md** | Guide de démarrage en 3 étapes |
| **INTEGRATION_REACT_EXPRESS.md** | Documentation complète de l'intégration |
| **EXPLICATION_CODE.md** | Code backend expliqué ligne par ligne |
| **MODIFICATIONS_REACT.md** | Détails des modifications React |
| **TESTS_INTEGRATION.md** | Guide de tests complet |
| **express-js/README.md** | Documentation de l'API |
| **react-js/README.md** | Documentation du frontend |

---

## Commandes utiles

```bash
# Backend
cd express-js
npm run dev          # Démarrer en mode développement
npm start            # Démarrer en mode production

# Frontend
cd react-js
npm start            # Démarrer le serveur de développement
npm run build        # Build de production
```

---

## Ports utilisés

| Service | Port | URL |
|---------|------|-----|
| React | 3000 | http://localhost:3000 |
| Express | 5000 | http://localhost:5000 |
| MongoDB | - | Cloud (Atlas) |

---

## Prochaines étapes

1. ✅ Backend Express.js + MongoDB
2. ✅ Frontend React connecté
3. ✅ CRUD complet fonctionnel
4. ⏳ Ajouter des projets réels
5. ⏳ Personnaliser le design
6. ⏳ Ajouter l'authentification
7. ⏳ Déployer en production (Vercel, Heroku, etc.)

---

## Auteur

**Groupe 1**  
Date : 28 Avril 2026  
Version : 1.0

---

## Licence

Projet éducatif - Portfolio personnel

---

## Support

Pour toute question ou problème :
1. Consulter la documentation dans le dossier racine
2. Vérifier les logs dans les terminaux
3. Ouvrir la console du navigateur (F12)
4. Vérifier MongoDB Compass pour la base de données

---

**Bon développement ! 🚀**
