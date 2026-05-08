import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Project from './src/models/Project.js';

dotenv.config();

const projects = [
    {
        title: "Application de gestion des étudiants",
        description: "Application web complète permettant la gestion des étudiants, authentification incluse. Cette application offre une interface intuitive pour gérer les informations des étudiants, leurs notes, et leur parcours académique.",
        shortDescription: "Application web complète permettant la gestion des étudiants avec authentification",
        technologies: ["Vue.js", "Laravel", "MySQL"],
        image: "http://localhost:3000/assets/appEtudiant.png",
        github: "https://github.com/example/app-etudiants",
        demo: "https://demo.example.com"
    },
    {
        title: "Pipeline CI/CD avec GitHub Actions",
        description: "Automatisation du build, test et déploiement continu d'une application web grâce à GitHub Actions. Ce projet démontre la mise en place d'un pipeline complet avec tests automatisés, analyse de code et déploiement automatique.",
        shortDescription: "Automatisation du build, test et déploiement avec GitHub Actions",
        technologies: ["GitHub Actions", "Docker", "AWS"],
        image: "http://localhost:3000/assets/CI-CD.png",
        github: "https://github.com/example/ci-cd-pipeline",
        demo: "https://demo.example.com"
    },
    {
        title: "Monitoring avec CloudWatch",
        description: "Mise en place d'un système de monitoring et d'alertes avec AWS CloudWatch pour surveiller les performances et la santé des applications en production. Inclut des dashboards personnalisés et des alertes automatiques.",
        shortDescription: "Système de monitoring et d'alertes avec AWS CloudWatch",
        technologies: ["AWS CloudWatch", "Lambda", "SNS"],
        image: "http://localhost:3000/assets/cloudWatch.png",
        github: "https://github.com/example/cloudwatch-monitoring",
        demo: "https://demo.example.com"
    },
    {
        title: "Déploiement d'instances EC2",
        description: "Automatisation du déploiement et de la configuration d'instances EC2 sur AWS avec Terraform. Ce projet inclut la configuration de groupes de sécurité, load balancers et auto-scaling.",
        shortDescription: "Automatisation du déploiement d'instances EC2 avec Terraform",
        technologies: ["AWS EC2", "Terraform", "Ansible"],
        image: "http://localhost:3000/assets/ec2.png",
        github: "https://github.com/example/ec2-deployment",
        demo: "https://demo.example.com"
    },
    {
        title: "Application Laravel E-commerce",
        description: "Développement d'une plateforme e-commerce complète avec Laravel. Fonctionnalités : gestion des produits, panier, paiement en ligne, gestion des commandes et interface d'administration.",
        shortDescription: "Plateforme e-commerce complète développée avec Laravel",
        technologies: ["Laravel", "PHP", "MySQL", "Stripe"],
        image: "http://localhost:3000/assets/laravel.png",
        github: "https://github.com/example/laravel-ecommerce",
        demo: "https://demo.example.com"
    }
];

const seedProjects = async () => {
    try {
        // Connexion à MongoDB
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connecté à MongoDB');

        // Supprimer tous les projets existants
        await Project.deleteMany({});
        console.log('🗑️  Projets existants supprimés');

        // Insérer les nouveaux projets
        const insertedProjects = await Project.insertMany(projects);
        console.log(`✅ ${insertedProjects.length} projets insérés avec succès`);

        // Afficher les projets insérés
        console.log('\n📋 Projets insérés :');
        insertedProjects.forEach((project, index) => {
            console.log(`${index + 1}. ${project.title}`);
        });

        process.exit(0);
    } catch (error) {
        console.error('❌ Erreur lors du seeding:', error.message);
        process.exit(1);
    }
};

seedProjects();
