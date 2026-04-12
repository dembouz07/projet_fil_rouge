/**
 * projectDetail.js
 * Page détail d'un projet
 */

import { getProjectBySlug } from "../services/projectService.js";

/**
 * Monte la page détail d'un projet
 * @param {HTMLElement} container
 * @param {string} slug - identifiant du projet
 * @param {Function} onNavigate - callback(page, params)
 */
export function mountProjectDetail(container, slug, onNavigate) {
  const project = getProjectBySlug(slug);

  if (!project) {
    container.innerHTML = `
      <section class="min-h-screen flex items-center justify-center pt-16">
        <div class="text-center">
          <h2 class="text-4xl font-bold text-gray-800 mb-4">Projet introuvable</h2>
          <p class="text-gray-600 mb-6">Ce projet n'existe pas ou a été supprimé.</p>
          <button id="back-btn" class="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition">
            ← Retour aux projets
          </button>
        </div>
      </section>
    `;
    container.querySelector("#back-btn").addEventListener("click", () => {
      if (onNavigate) onNavigate("projects");
    });
    return;
  }

  container.innerHTML = `
    <section class="pt-24 pb-20 min-h-screen">
      <div class="container mx-auto px-6">
        <button id="back-btn"
          class="text-blue-600 font-semibold hover:underline mb-8 inline-flex items-center gap-2 transition">
          <i class="fas fa-arrow-left"></i> Retour aux projets
        </button>

        <div class="grid md:grid-cols-2 gap-12 items-center">
          <img 
            src="${project.image}" 
            alt="${project.title}"
            class="rounded-2xl shadow-lg w-full object-cover"
            onerror="this.src='https://via.placeholder.com/600x400?text=${encodeURIComponent(project.title)}'">

          <div>
            <h1 class="text-4xl font-bold text-gray-800 mb-4">
              ${project.title}
            </h1>
            <p class="text-gray-600 mb-8 leading-relaxed text-lg">
              ${project.description}
            </p>

            <h3 class="text-xl font-semibold mb-4 text-gray-800">Technologies</h3>
            <div class="flex flex-wrap gap-3 mb-8">
              ${project.technologies
                .map(
                  (tech) =>
                    `<span class="bg-blue-100 text-blue-600 px-4 py-2 rounded-full font-medium">${tech}</span>`
                )
                .join("")}
            </div>

            <div class="flex gap-4">
              <a href="${project.demoUrl}"
                class="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition flex items-center gap-2">
                <i class="fas fa-eye"></i> Demo
              </a>
              <a href="${project.githubUrl}"
                class="bg-gray-800 text-white px-6 py-3 rounded-lg hover:bg-gray-900 transition flex items-center gap-2">
                <i class="fab fa-github"></i> Code
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
  `;

  container.querySelector("#back-btn").addEventListener("click", () => {
    if (onNavigate) onNavigate("projects");
  });
}