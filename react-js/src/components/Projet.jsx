/**
 * Projet.jsx
 * Affiche le libellé et l'image d'un projet ainsi qu'un bouton Supprimer.
 * Le libellé est une ancre dont le clic affiche le détail du projet.
 */

import { useNavigate } from 'react-router-dom'

export default function Projet({ project, onDelete }) {
    const navigate = useNavigate()

    return (
        <div className="card">
            {/* Image */}
            <img
                src={project.image}
                alt={project.title}
                className="project-card-img"
                onError={e => { e.target.src = `https://placehold.co/600x400/94a3b8/white?text=${encodeURIComponent(project.title)}` }}
            />

            <div className="project-card-body">
                {/* Libellé — ancre vers le détail */}
                <h3
                    className="project-card-title"
                    onClick={() => navigate(`/projets/${project.id}`)}
                    title="Voir le détail"
                >
                    {project.title}
                </h3>

                {/* Description courte */}
                <p className="project-card-desc">{project.shortDescription}</p>

                {/* Badges technologies */}
                <div className="project-card-tags">
                    {(project.technologies || []).slice(0, 3).map(tech => (
                        <span key={tech} className="badge">{tech}</span>
                    ))}
                </div>

                {/* Actions */}
                <div className="project-card-actions">
                    <button
                        className="btn btn-primary btn-sm"
                        onClick={() => navigate(`/projets/${project.id}`)}
                    >
                        <i className="fas fa-eye" /> Voir
                    </button>
                    <button
                        className="btn btn-warning btn-sm"
                        onClick={() => navigate(`/projets/${project.id}/editer`)}
                    >
                        <i className="fas fa-pen" /> Modifier
                    </button>
                    <button
                        className="btn btn-danger btn-sm"
                        onClick={() => onDelete(project)}
                    >
                        <i className="fas fa-trash" /> Supprimer
                    </button>
                </div>
            </div>
        </div>
    )
}