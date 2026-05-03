import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import connectDB from './src/config/database.js';
import projectRoutes from './src/routes/projectRoutes.js';
import { errorHandler } from './src/middleware/errorHandler.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

connectDB();

app.use(cors({
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
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
