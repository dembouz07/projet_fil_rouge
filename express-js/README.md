# Portfolio API - Express.js + MongoDB

API REST pour gerer les projets du portfolio.

## Prerequis

- Node.js (v16+)
- MongoDB Atlas
- npm

## Installation

```bash
# 1. Installer les dependances
npm install

# 2. Demarrer le serveur
npm run dev
```

Serveur : `http://localhost:5000`

## Structure

- `.env` - Variables d'environnement
- `app.js` - Point d'entree
- `src/config/database.js` - Connexion MongoDB
- `src/models/Project.js` - Modele de donnees
- `src/controllers/projectController.js` - Logique metier (CRUD)
- `src/routes/projectRoutes.js` - Routes API
- `src/middleware/` - Validation et gestion d'erreurs

## Endpoints

| Methode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/projects` | Liste tous les projets |
| GET | `/api/projects/:id` | Details d'un projet |
| POST | `/api/projects` | Creer un projet |
| PUT | `/api/projects/:id` | Modifier un projet |
| DELETE | `/api/projects/:id` | Supprimer un projet |

## Variables d'Environnement

```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/portfolio
CORS_ORIGIN=http://localhost:3000
```
