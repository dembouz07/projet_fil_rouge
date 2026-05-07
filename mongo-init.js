// Script d'initialisation de la base de données MongoDB
db = db.getSiblingDB('portfolio');

// Créer la collection projects
db.createCollection('projects');

// Insérer des données de démonstration
db.projects.insertMany([
  {
    title: "Application de gestion des étudiants",
    description: "Application web complète permettant la gestion des étudiants, authentification incluse",
    shortDescription: "Application web complète permettant la gestion des étudiants avec authentification",
    technologies: ["Vue.js", "Laravel", "MySQL"],
    image: "https://placehold.co/400x200/3b82f6/white?text=App+Etudiants",
    github: "https://github.com/example/app-etudiants",
    demo: "https://demo.example.com",
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    title: "Pipeline CI/CD avec GitHub Actions",
    description: "Automatisation du build, test et déploiement continu d'une application web grâce à GitHub Actions",
    shortDescription: "Automatisation du build, test et déploiement avec GitHub Actions",
    technologies: ["GitHub Actions", "Docker", "AWS"],
    image: "https://placehold.co/400x200/10b981/white?text=CI/CD",
    github: "https://github.com/example/ci-cd-pipeline",
    demo: "https://demo.example.com",
    createdAt: new Date(),
    updatedAt: new Date()
  }
]);

print('Base de données initialisée avec succès !');
