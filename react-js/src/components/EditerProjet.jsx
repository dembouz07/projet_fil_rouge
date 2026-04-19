/**
 * EditerProjet.jsx
 * Formulaire de modification d'un projet existant.
 * Charge le projet par id, puis utilise ProjectForm pré-rempli.
 */

import { useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { updateProject } from '../services/projectService.js'
import { useProject } from '../hooks/useProject.js'
import ProjectForm from './ui/ProjectForm.jsx'
import Spinner from './ui/Spinner.jsx'
import Alert from './ui/Alert.jsx'

export default function EditerProjet() {
    const { id }   = useParams()
    const navigate = useNavigate()
    const { project, loading, error } = useProject(id)
    const [success, setSuccess] = useState(false)

    async function handleSubmit(formData) {
        await updateProject(id, formData)
        setSuccess(true)
        setTimeout(() => navigate(`/projets/${id}`), 1500)
    }

    if (loading) return <div className="page"><Spinner text="Chargement du projet…" /></div>

    if (error || !project) return (
        <div className="page">
            <div className="container" style={{ padding: '3rem 2rem', textAlign: 'center' }}>
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
                <div className="card form-card">

                    <h2 className="form-title">Modifier le Projet</h2>
                    <div className="form-bar" style={{ background: 'var(--accent)' }} />
                    <p style={{ color: 'var(--gray-600)', marginBottom: '1.5rem', fontSize: '.9rem' }}>
                        Modification de : <strong>{project.title}</strong>
                    </p>

                    {success && (
                        <Alert type="success">Projet modifié avec succès ! Redirection…</Alert>
                    )}

                    <ProjectForm
                        initial={project}
                        onSubmit={handleSubmit}
                        onCancel={() => navigate(`/projets/${id}`)}
                        submitLabel="Enregistrer les modifications"
                        accentColor="var(--accent)"
                    />

                </div>
            </div>
        </div>
    )
}