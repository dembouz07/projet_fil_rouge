/**
 * Prometheus Metrics Middleware
 * Expose des métriques HTTP et custom pour le monitoring
 */

import client from 'prom-client';

// Registre pour toutes les métriques
const register = new client.Registry();

// Métriques système par défaut (CPU, RAM, etc.)
client.collectDefaultMetrics({
  register,
  prefix: 'portfolio_backend_',
  gcDurationBuckets: [0.001, 0.01, 0.1, 1, 2, 5],
});

// ========================================
// MÉTRIQUES HTTP
// ========================================

// Compteur de requêtes HTTP
const httpRequestsTotal = new client.Counter({
  name: 'portfolio_backend_http_requests_total',
  help: 'Nombre total de requêtes HTTP',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register],
});

// Durée des requêtes HTTP
const httpRequestDuration = new client.Histogram({
  name: 'portfolio_backend_http_request_duration_seconds',
  help: 'Durée des requêtes HTTP en secondes',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 2, 5],
  registers: [register],
});

// Requêtes HTTP en cours
const httpRequestsInProgress = new client.Gauge({
  name: 'portfolio_backend_http_requests_in_progress',
  help: 'Nombre de requêtes HTTP en cours de traitement',
  labelNames: ['method', 'route'],
  registers: [register],
});

// ========================================
// MÉTRIQUES MONGODB
// ========================================

// Opérations MongoDB
const mongoOperationsTotal = new client.Counter({
  name: 'portfolio_backend_mongo_operations_total',
  help: 'Nombre total d\'opérations MongoDB',
  labelNames: ['operation', 'collection', 'status'],
  registers: [register],
});

// Durée des opérations MongoDB
const mongoOperationDuration = new client.Histogram({
  name: 'portfolio_backend_mongo_operation_duration_seconds',
  help: 'Durée des opérations MongoDB en secondes',
  labelNames: ['operation', 'collection'],
  buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1],
  registers: [register],
});

// ========================================
// MÉTRIQUES BUSINESS
// ========================================

// Nombre de projets en base
const projectsCount = new client.Gauge({
  name: 'portfolio_backend_projects_count',
  help: 'Nombre total de projets en base de données',
  registers: [register],
});

// Erreurs applicatives
const applicationErrors = new client.Counter({
  name: 'portfolio_backend_errors_total',
  help: 'Nombre total d\'erreurs applicatives',
  labelNames: ['type', 'route'],
  registers: [register],
});

// ========================================
// MIDDLEWARE EXPRESS
// ========================================

/**
 * Middleware pour tracker les métriques HTTP
 */
const metricsMiddleware = (req, res, next) => {
  // Ignorer l'endpoint /metrics lui-même
  if (req.path === '/metrics') {
    return next();
  }

  const start = Date.now();
  const route = req.route?.path || req.path || 'unknown';

  // Incrémenter les requêtes en cours
  httpRequestsInProgress.inc({ method: req.method, route });

  // Hook sur la fin de la réponse
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const statusCode = res.statusCode;

    // Enregistrer les métriques
    httpRequestsTotal.inc({ method: req.method, route, status_code: statusCode });
    httpRequestDuration.observe({ method: req.method, route, status_code: statusCode }, duration);
    httpRequestsInProgress.dec({ method: req.method, route });
  });

  next();
};

/**
 * Tracker les opérations MongoDB
 */
const trackMongoOperation = async (operation, collection, callback) => {
  const start = Date.now();
  let status = 'success';

  try {
    const result = await callback();
    return result;
  } catch (error) {
    status = 'error';
    throw error;
  } finally {
    const duration = (Date.now() - start) / 1000;
    mongoOperationsTotal.inc({ operation, collection, status });
    mongoOperationDuration.observe({ operation, collection }, duration);
  }
};

/**
 * Mettre à jour le compteur de projets
 */
const updateProjectsCount = (count) => {
  projectsCount.set(count);
};

/**
 * Tracker une erreur applicative
 */
const trackError = (type, route) => {
  applicationErrors.inc({ type, route });
};

// ========================================
// EXPORT
// ========================================

export {
  register,
  metricsMiddleware,
  trackMongoOperation,
  updateProjectsCount,
  trackError,
};

export const metrics = {
  httpRequestsTotal,
  httpRequestDuration,
  httpRequestsInProgress,
  mongoOperationsTotal,
  mongoOperationDuration,
  projectsCount,
  applicationErrors,
};

