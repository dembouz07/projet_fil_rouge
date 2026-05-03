import { body, validationResult } from 'express-validator';

export const validateProject = [
    body('title')
        .trim()
        .notEmpty().withMessage('Le titre est obligatoire')
        .isLength({ max: 200 }).withMessage('Le titre ne peut pas dépasser 200 caractères'),
    
    body('shortDescription')
        .optional()
        .trim()
        .isLength({ max: 300 }).withMessage('La description courte ne peut pas dépasser 300 caractères'),
    
    body('description')
        .trim()
        .notEmpty().withMessage('La description est obligatoire'),
    
    body('technologies')
        .custom((value) => {
            if (Array.isArray(value)) {
                return value.length > 0;
            }
            if (typeof value === 'string') {
                return value.trim().length > 0;
            }
            return false;
        })
        .withMessage('Au moins une technologie est requise'),
    
    body('image')
        .optional({ checkFalsy: true })
        .trim()
        .isURL().withMessage('L\'URL de l\'image doit être valide'),
    
    body('demoUrl')
        .optional()
        .trim(),
    
    body('githubUrl')
        .optional()
        .trim(),
    
    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({
                success: false,
                message: 'Erreur de validation',
                errors: errors.array().map(err => err.msg)
            });
        }
        next();
    }
];
