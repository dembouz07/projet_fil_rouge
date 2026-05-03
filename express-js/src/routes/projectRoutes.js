import express from 'express';
import {
    getAllProjects,
    getProjectById,
    createProject,
    updateProject,
    deleteProject
} from '../controllers/projectController.js';
import { validateProject } from '../middleware/validators.js';

const router = express.Router();

router.get('/', getAllProjects);
router.get('/:id', getProjectById);
router.post('/', validateProject, createProject);
router.put('/:id', validateProject, updateProject);
router.delete('/:id', deleteProject);

export default router;
