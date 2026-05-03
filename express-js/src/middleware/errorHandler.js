export const errorHandler = (err, req, res, next) => {
    console.error('Erreur:', err);
    
    let statusCode = err.statusCode || 500;
    let message = err.message || 'Erreur serveur interne';
    
    if (err.code === 11000) {
        statusCode = 400;
        const field = Object.keys(err.keyPattern)[0];
        message = `Ce ${field} existe deja`;
    }
    
    if (err.name === 'CastError') {
        statusCode = 404;
        message = 'Ressource introuvable';
    }
    
    if (err.name === 'ValidationError') {
        statusCode = 400;
        message = Object.values(err.errors).map(e => e.message).join(', ');
    }
    
    res.status(statusCode).json({
        success: false,
        message,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
};
