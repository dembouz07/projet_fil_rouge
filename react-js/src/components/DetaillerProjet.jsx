/**
 * DetaillerProjet.jsx
 * Affiche les informations complètes d'un projet.
 * Bouton "Annuler" → retour à la liste
 * Bouton "Editer"  → page d'édition
 * Bouton "Supprimer" → modale de confirmation
 */

import { useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { deleteProject } from '../services/projectService.js'
import { useProject } from '../hooks/useProject.js'
import Modal from './ui/Modal.jsx'
import Spinner from './ui/Spinner.jsx'

export default function DetaillerProjet() {
    const { id }   = useParams()
    const navigate = useNavigate()
    const { project, loading, error } = useProject(id)
    const [deleteModal, setDeleteModal] = useState(false)

    async function handleDeleteConfirm() {
        try {
            await deleteProject(id)
            navigate('/projets')
        } catch {
            setDeleteModal(false)
        }
    }

    if (loading) return <div className="page"><Spinner /></div>

    if (error || !project) return (
        <div className="page">
            <div className="container" style={{ padding: '3rem 2rem', textAlign: 'center' }}>
                <i className="fas fa-exclamation-triangle" style={{ fontSize: '3rem', color: 'var(--danger)', marginBottom: '1rem', display: 'block' }} />
                <h2 style={{ marginBottom: '1rem' }}>Projet introuvable</h2>
                <button className="btn btn-primary" onClick={() => navigate('/projets')}>
                    ← Retour aux projets
                </button>
            </div>
        </div>
    )

    return (
        <div className="page">
            <div className="container" style={{ padding: '2.5rem 2rem' }}>

                {/* Bouton retour / Annuler */}
                <button className="back-link" onClick={() => navigate('/projets')}>
                    <i className="fas fa-arrow-left" /> Retour aux projets
                </button>

                <div className="detail-grid">

                    {/* Image */}
                    <img
                        src={project.image}
                        alt={project.title}
                        className="detail-img"
                        onError={e => { e.target.src = `https://placehold.co/600x400/94a3b8/white?text=${encodeURIComponent(project.title)}` }}
                    />

                    {/* Infos */}
                    <div>
                        <h1 className="detail-title">{project.title}</h1>
                        <p className="detail-desc">{project.description}</p>

                        <h3 style={{ marginBottom: '.75rem', color: 'var(--navy)' }}>Technologies</h3>
                        <div className="detail-tags">
                            {(project.technologies || []).map(tech => (
                                <span key={tech} className="badge" style={{ fontSize: '.9rem', padding: '.35rem 1rem' }}>
                  {tech}
                </span>
                            ))}
                        </div>

                        {/* Actions */}
                        <div className="detail-actions">
                            {project.demoUrl && project.demoUrl !== '#' && (
                                <a href={project.demoUrl} target="_blank" rel="noreferrer" className="btn btn-primary">
                                    <i className="fas fa-eye" /> Demo
                                </a>
                            )}
                            {project.githubUrl && project.githubUrl !== '#' && (
                                <a href={project.githubUrl} target="_blank" rel="noreferrer" className="btn btn-secondary">
                                    <i className="fab fa-github" /> Code
                                </a>
                            )}

                            {/* Bouton Editer */}
                            <button
                                className="btn btn-warning"
                                onClick={() => navigate(`/projets/${project.id}/editer`)}
                            >
                                <i className="fas fa-pen" /> Editer
                            </button>

                            {/* Bouton Supprimer */}
                            <button
                                className="btn btn-danger"
                                onClick={() => setDeleteModal(true)}
                            >
                                <i className="fas fa-trash" /> Supprimer
                            </button>

                            {/* Bouton Annuler */}
                            <button
                                className="btn btn-ghost"
                                onClick={() => navigate('/projets')}
                            >
                                <i className="fas fa-times" /> Annuler
                            </button>
                        </div>
                    </div>

                </div>
            </div>

            {/* Modale de confirmation suppression */}
            {deleteModal && (
                <Modal
                    title="Supprimer le projet ?"
                    message={`Vous allez supprimer "${project.title}". Cette action est irréversible.`}
                    onConfirm={handleDeleteConfirm}
                    onCancel={() => setDeleteModal(false)}
                    danger
                    confirmLabel="Supprimer"
                />
            )}
        </div>
    )
}