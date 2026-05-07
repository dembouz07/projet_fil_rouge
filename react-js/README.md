# Portfolio React - Frontend

Application React pour gérer un portfolio de projets, connectée à une API Express.js + MongoDB.

## Configuration

### Backend requis
Le backend Express.js doit être démarré sur le port 5000.

```bash
cd ../express-js
npm run dev
```

### URL de l'API
```javascript
http://localhost:5000/api/projects
```

Configurée dans `src/services/projectService.js`

---

## Installation

```bash
npm install
```

---

## Démarrage

```bash
npm start
```

Ouvre http://localhost:3000 dans le navigateur.

---

## Structure du projet

```
src/
├── components/          # Composants React
│   ├── Projet.jsx       # Carte projet
│   ├── AjouterProjet.jsx
│   ├── EditerProjet.jsx
│   ├── DetaillerProjet.jsx
│   ├── Navbar.jsx
│   ├── Footer.jsx
│   └── ui/              # Composants UI réutilisables
├── pages/               # Pages
│   ├── Home.jsx
│   ├── Contact.jsx
│   └── NotFound.jsx
├── services/            # Services API
│   └── projectService.js  # Appels API vers Express
├── hooks/               # Hooks personnalisés
│   ├── useProjects.js   # Gestion état projets
│   └── useProject.js    # Gestion projet unique
├── App.jsx              # Routes
└── index.js             # Point d'entrée
```

---

## Services API

### `src/services/projectService.js`

Toutes les fonctions pour communiquer avec l'API Express.js :

```javascript
getAllProjects()        // GET /api/projects
getProjectById(id)      // GET /api/projects/:id
addProject(data)        // POST /api/projects
updateProject(id, data) // PUT /api/projects/:id
deleteProject(id)       // DELETE /api/projects/:id
```

**Normalisation des IDs :**
MongoDB utilise `_id`, React utilise `id`. La fonction `normalizeProject()` convertit automatiquement `_id` en `id`.

---

## Hooks personnalisés

### `useProjects()`
Gère la liste complète des projets.

```javascript
const { projects, loading, error, fetchProjects, addProject, updateProject, deleteProject } = useProjects()
```

### `useProject(id)`
Gère un projet unique.

```javascript
const { project, loading, error } = useProject(id)
```

---

## Fonctionnalités

- ✅ Lister tous les projets
- ✅ Voir les détails d'un projet
- ✅ Ajouter un nouveau projet
- ✅ Modifier un projet existant
- ✅ Supprimer un projet
- ✅ Validation des formulaires
- ✅ Gestion des erreurs
- ✅ Loading states
- ✅ Responsive design (Tailwind CSS)

---

## Technologies

- **React** 19.2.5
- **React Router** 7.14.1
- **Tailwind CSS** (via input.css)
- **Fetch API** (requêtes HTTP)

---

## Scripts disponibles

```bash
npm start       # Démarrer en mode développement
npm run build   # Build pour production
npm test        # Lancer les tests
```

---

## Configuration CORS

Le backend Express doit autoriser l'origine React :

```env
# express-js/.env
CORS_ORIGIN=http://localhost:3000
```

---

## Gestion des erreurs

### Backend non démarré
```
Impossible de charger les projets. 
Vérifiez que le serveur Express.js est lancé sur le port 5000.
```

### Validation
Les erreurs de validation du backend sont affichées dans l'interface.

---

## Différences avec json-server

| Aspect | json-server | Express + MongoDB |
|--------|-------------|-------------------|
| URL | `localhost:3001/projects` | `localhost:5000/api/projects` |
| ID | Numérique (1, 2, 3) | String (`_id`) |
| Validation | Aucune | express-validator |
| Production | Non recommandé | Production-ready |

---

## Documentation

- **BACKEND_CONNECTION.md** - Configuration de la connexion backend
- **../INTEGRATION_REACT_EXPRESS.md** - Documentation complète de l'intégration
- **../MODIFICATIONS_REACT.md** - Détails des modifications apportées
- **../TESTS_INTEGRATION.md** - Guide de tests

---

## Démarrage rapide

### 1. Démarrer le backend
```bash
cd ../express-js
npm run dev
```

### 2. Démarrer le frontend
```bash
npm start
```

### 3. Ouvrir le navigateur
http://localhost:3000

---

## Dépannage

### Erreur : "Failed to fetch"
**Solution :** Vérifier que Express tourne sur port 5000

### Erreur : "CORS policy"
**Solution :** Vérifier `CORS_ORIGIN` dans `express-js/.env`

### Projets ne s'affichent pas
**Solution :** 
1. Vérifier que MongoDB est connecté
2. Ouvrir la console du navigateur (F12)
3. Vérifier les erreurs réseau

---

## Auteur

Kiro AI - 28 Avril 2026

---

## Licence

Ce projet est un projet éducatif.
