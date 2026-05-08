import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import connectDB from './src/config/database.js';
import projectRoutes from './src/routes/projectRoutes.js';
import { errorHandler } from './src/middleware/errorHandler.js';

dotenv.config();

console.log('MONGODB_URI:', process.env.MONGODB_URI);
console.log('PORT:', process.env.PORT);

const app = express();
const PORT = process.env.PORT || 5000;

connectDB();

// Configuration CORS pour accepter plusieurs origines
const allowedOrigins = [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://172.16.146.1:3000'
];

app.use(cors({
    origin: function (origin, callback) {
        console.log('Origin reçue:', origin);
        
        // Autoriser les requêtes sans origin (comme Postman, curl)
        if (!origin) return callback(null, true);
        
        // En développement, autoriser toutes les origines
        if (process.env.NODE_ENV === 'development') {
            return callback(null, true);
        }
        
        // En production, vérifier la liste
        if (allowedOrigins.indexOf(origin) !== -1) {
            callback(null, true);
        } else {
            console.error('Origin non autorisée:', origin);
            callback(new Error('Non autorisé par CORS'));
        }
    },
    credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
    res.json({
        message: 'Bienvenue sur l\'API Portfolio',
        version: '1.0.0',
        endpoints: {
            projects: '/api/projects'
        }
    });
});

app.use('/api/projects', projectRoutes);
app.use(errorHandler);

app.listen(PORT, () => {
    console.log(`Serveur demarre sur le port ${PORT}`);
    console.log(`URL: http://localhost:${PORT}`);
    console.log(`Environnement: ${process.env.NODE_ENV}`);
});
