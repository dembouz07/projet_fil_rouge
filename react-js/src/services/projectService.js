/**
 * projectService.js
 * Toutes les requêtes HTTP vers l'API Express.js + MongoDB
 */

// URL de l'API - utilise l'URL Docker en production
const BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api/projects';

/**
 * Normalise l'ID MongoDB (_id) en id pour compatibilité avec React
 * @param {Object} project
 * @returns {Object}
 */
function normalizeProject(project) {
    if (project._id && !project.id) {
        return { ...project, id: project._id };
    }
    return project;
}

/**
 * Récupère tous les projets
 * @returns {Promise<Array>}
 */
export async function getAllProjects() {
    const res = await fetch(BASE_URL);
    if (!res.ok) throw new Error('Erreur lors de la récupération des projets');
    const response = await res.json();
    const data = response.data || response; // Support des deux formats
    return Array.isArray(data) ? data.map(normalizeProject) : [];
}

/**
 * Récupère un projet par son id
 * @param {string} id
 * @returns {Promise<Object>}
 */
export async function getProjectById(id) {
    const res = await fetch(`${BASE_URL}/${id}`);
    if (!res.ok) throw new Error('Projet introuvable');
    const response = await res.json();
    const data = response.data || response; // Support des deux formats
    return normalizeProject(data);
}

/**
 * Ajoute un nouveau projet
 * @param {Object} projectData
 * @returns {Promise<Object>} projet créé avec _id généré par MongoDB
 */
export async function addProject(projectData) {
    const res = await fetch(BASE_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            ...projectData,
            technologies: typeof projectData.technologies === 'string'
                ? projectData.technologies.split(',').map(t => t.trim()).filter(Boolean)
                : projectData.technologies,
        }),
    });
    if (!res.ok) {
        const errorData = await res.json();
        throw new Error(errorData.message || 'Erreur lors de l\'ajout du projet');
    }
    const response = await res.json();
    const data = response.data || response; // Support des deux formats
    return normalizeProject(data);
}

/**
 * Met à jour un projet existant
 * @param {string} id - ID MongoDB (_id)
 * @param {Object} projectData
 * @returns {Promise<Object>} projet mis à jour
 */
export async function updateProject(id, projectData) {
    const res = await fetch(`${BASE_URL}/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            ...projectData,
            technologies: typeof projectData.technologies === 'string'
                ? projectData.technologies.split(',').map(t => t.trim()).filter(Boolean)
                : projectData.technologies,
        }),
    });
    if (!res.ok) {
        const errorData = await res.json();
        throw new Error(errorData.message || 'Erreur lors de la mise à jour du projet');
    }
    const response = await res.json();
    const data = response.data || response; // Support des deux formats
    return normalizeProject(data);
}

/**
 * Supprime un projet par son id
 * @param {string} id - ID MongoDB (_id)
 * @returns {Promise<void>}
 */
export async function deleteProject(id) {
    const res = await fetch(`${BASE_URL}/${id}`, { method: 'DELETE' });
    if (!res.ok) {
        const errorData = await res.json();
        throw new Error(errorData.message || 'Erreur lors de la suppression du projet');
    }
}