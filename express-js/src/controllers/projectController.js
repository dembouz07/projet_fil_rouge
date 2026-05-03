import Project from '../models/Project.js';

export const getAllProjects = async (req, res, next) => {
    try {
        const projects = await Project.find().sort({ createdAt: -1 });
        res.status(200).json({
            success: true,
            count: projects.length,
            data: projects
        });
    } catch (error) {
        next(error);
    }
};

export const getProjectById = async (req, res, next) => {
    try {
        const project = await Project.findById(req.params.id);
        
        if (!project) {
            return res.status(404).json({
                success: false,
                message: 'Projet introuvable'
            });
        }
        
        res.status(200).json({
            success: true,
            data: project
        });
    } catch (error) {
        if (error.kind === 'ObjectId') {
            return res.status(404).json({
                success: false,
                message: 'Projet introuvable'
            });
        }
        next(error);
    }
};

export const createProject = async (req, res, next) => {
    try {
        if (typeof req.body.technologies === 'string') {
            req.body.technologies = req.body.technologies
                .split(',')
                .map(t => t.trim())
                .filter(Boolean);
        }
        
        const project = await Project.create(req.body);
        
        res.status(201).json({
            success: true,
            message: 'Projet créé avec succès',
            data: project
        });
    } catch (error) {
        if (error.name === 'ValidationError') {
            const messages = Object.values(error.errors).map(err => err.message);
            return res.status(400).json({
                success: false,
                message: 'Erreur de validation',
                errors: messages
            });
        }
        next(error);
    }
};

export const updateProject = async (req, res, next) => {
    try {
        if (typeof req.body.technologies === 'string') {
            req.body.technologies = req.body.technologies
                .split(',')
                .map(t => t.trim())
                .filter(Boolean);
        }
        
        const project = await Project.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );
        
        if (!project) {
            return res.status(404).json({
                success: false,
                message: 'Projet introuvable'
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Projet mis à jour avec succès',
            data: project
        });
    } catch (error) {
        if (error.name === 'ValidationError') {
            const messages = Object.values(error.errors).map(err => err.message);
            return res.status(400).json({
                success: false,
                message: 'Erreur de validation',
                errors: messages
            });
        }
        if (error.kind === 'ObjectId') {
            return res.status(404).json({
                success: false,
                message: 'Projet introuvable'
            });
        }
        next(error);
    }
};

export const deleteProject = async (req, res, next) => {
    try {
        const project = await Project.findByIdAndDelete(req.params.id);
        
        if (!project) {
            return res.status(404).json({
                success: false,
                message: 'Projet introuvable'
            });
        }
        
        res.status(200).json({
            success: true,
            message: 'Projet supprimé avec succès',
            data: {}
        });
    } catch (error) {
        if (error.kind === 'ObjectId') {
            return res.status(404).json({
                success: false,
                message: 'Projet introuvable'
            });
        }
        next(error);
    }
};
