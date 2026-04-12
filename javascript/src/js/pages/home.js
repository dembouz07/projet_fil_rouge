/**
 * home.js
 * Page d'accueil du portfolio
 */

/**
 * Retourne le HTML de la page d'accueil
 * @param {Function} onNavigate - callback(page, params)
 * @returns {string} HTML string
 */
export function renderHome(onNavigate) {
  return `
    <!-- HERO -->
    <section class="bg-gray-100 min-h-screen flex items-center pt-16">
      <div class="container mx-auto px-6 grid md:grid-cols-2 gap-12 items-center py-20">
        <div>
          <p class="text-blue-600 text-lg mb-2 animate-fade-in">Bonjour, je suis</p>
          <h1 class="text-5xl font-bold text-gray-900 mb-4">Ousseynou Faye</h1>
          <h2 class="text-2xl text-gray-700 mb-6">
            Apprenant AWS re/Start • Développeur Full Stack • Passionné de Cloud et DevOps
          </h2>
          <p class="text-gray-600 leading-relaxed mb-8 max-w-xl">
            Je conçois et développe des applications web modernes, robustes et évolutives. 
            Passionné par la résolution de problèmes, je transforme des idées en solutions 
            performantes en combinant développement logiciel, Cloud et DevOps.
          </p>
          <div class="flex space-x-6 text-gray-600 text-2xl mb-8">
            <a href="#" class="hover:text-black transition"><i class="fab fa-github"></i></a>
            <a href="#" class="hover:text-blue-600 transition"><i class="fab fa-linkedin"></i></a>
            <a href="#" class="hover:text-gray-900 transition"><i class="fas fa-envelope"></i></a>
          </div>
          <div class="flex gap-4">
            <button data-nav="projects"
              class="nav-btn bg-blue-600 text-white px-8 py-3 rounded-lg hover:bg-blue-700 transition shadow-md">
              Projets
            </button>
            <button data-nav="contact"
              class="nav-btn border border-gray-300 px-8 py-3 rounded-lg hover:bg-gray-200 transition">
              Contacter Moi
            </button>
          </div>
        </div>
        <div class="flex justify-center">
          <div class="w-80 h-80 rounded-full overflow-hidden border-8 border-white shadow-xl">
            <img src="../public/assets/ouz.jpeg" alt="Photo Ousseynou Faye"
              class="w-full h-full object-cover"
              onerror="this.style.background='#3b82f6'">
          </div>
        </div>
      </div>
    </section>

    <!-- ABOUT -->
    <section id="about" class="bg-white py-20">
      <div class="container mx-auto px-6">
        <div class="text-center mb-16">
          <h2 class="text-4xl font-bold text-gray-900">À propos de moi</h2>
          <div class="w-24 h-1 bg-blue-600 mx-auto mt-4 rounded"></div>
        </div>
        <div class="grid md:grid-cols-2 gap-12 items-center">
          <div class="relative">
            <div class="absolute -right-6 -bottom-6 bg-blue-500 w-full h-full rounded-2xl opacity-20"></div>
            <img src="../public/assets/ouz.jpeg" alt="Ousseynou Faye"
              class="relative rounded-2xl shadow-lg w-full object-cover"
              onerror="this.style.background='#3b82f6'; this.style.height='400px'">
          </div>
          <div>
            <h3 class="text-3xl font-semibold text-gray-800 mb-6">Mon Parcours</h3>
            <p class="text-gray-600 leading-relaxed mb-6">
              Développeur logiciel passionné, je conçois et développe des applications modernes 
              en mettant l'accent sur la performance, la maintenabilité et l'expérience utilisateur.
            </p>
            <p class="text-gray-600 leading-relaxed mb-6">
              Actuellement en formation <strong>AWS Cloud & DevOps (AWS re/Start)</strong> 
              à Orange Digital Center, je renforce mes compétences en cloud computing, 
              automatisation, intégration et déploiement continu.
            </p>
            <p class="text-gray-600 leading-relaxed">
              Après avoir débuté en développement Front-End, j'ai évolué vers le Back-End 
              et le Full Stack, ce qui me permet aujourd'hui de concevoir des applications 
              complètes, du design jusqu'au déploiement dans le cloud.
            </p>
          </div>
        </div>
      </div>
    </section>
  `;
}

/**
 * Monte la page home et attache les événements
 * @param {HTMLElement} container
 * @param {Function} onNavigate
 */
export function mountHome(container, onNavigate) {
  container.innerHTML = renderHome(onNavigate);

  container.querySelectorAll(".nav-btn[data-nav]").forEach((btn) => {
    btn.addEventListener("click", () => {
      if (onNavigate) onNavigate(btn.dataset.nav);
    });
  });
}