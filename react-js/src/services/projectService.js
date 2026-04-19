/**
 * projectService.js
 * Toutes les requêtes HTTP vers json-server (http://localhost:3001/projects)
 */

const BASE_URL = 'http://localhost:3001/projects';

/**
 * Récupère tous les projets
 * @returns {Promise<Array>}
 */
export async function getAllProjects() {
    const res = await fetch(BASE_URL);
    if (!res.ok) throw new Error('Erreur lors de la récupération des projets');
    return res.json();
}

/**
 * Récupère un projet par son id
 * @param {number|string} id
 * @returns {Promise<Object>}
 */
export async function getProjectById(id) {
    const res = await fetch(`${BASE_URL}/${id}`);
    if (!res.ok) throw new Error('Projet introuvable');
    return res.json();
}

/**
 * Ajoute un nouveau projet
 * @param {Object} projectData
 * @returns {Promise<Object>} projet créé avec id généré par json-server
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
    if (!res.ok) throw new Error('Erreur lors de l\'ajout du projet');
    return res.json();
}

/**
 * Met à jour un projet existant (PUT = remplacement complet)
 * @param {number|string} id
 * @param {Object} projectData
 * @returns {Promise<Object>} projet mis à jour
 */
export async function updateProject(id, projectData) {
    const res = await fetch(`${BASE_URL}/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            ...projectData,
            id: Number(id),
            technologies: typeof projectData.technologies === 'string'
                ? projectData.technologies.split(',').map(t => t.trim()).filter(Boolean)
                : projectData.technologies,
        }),
    });
    if (!res.ok) throw new Error('Erreur lors de la mise à jour du projet');
    return res.json();
}

/**
 * Supprime un projet par son id
 * @param {number|string} id
 * @returns {Promise<void>}
 */
export async function deleteProject(id) {
    const res = await fetch(`${BASE_URL}/${id}`, { method: 'DELETE' });
    if (!res.ok) throw new Error('Erreur lors de la suppression du projet');
}