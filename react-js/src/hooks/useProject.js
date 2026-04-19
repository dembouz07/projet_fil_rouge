/**
 * useProject.js
 * Hook personnalisé pour charger un seul projet par son id.
 */

import { useState, useEffect } from 'react'
import { getProjectById } from '../services/projectService.js'

export function useProject(id) {
    const [project, setProject] = useState(null)
    const [loading, setLoading] = useState(true)
    const [error, setError]     = useState(null)

    useEffect(() => {
        if (!id) return
        let cancelled = false

        async function fetch() {
            try {
                setLoading(true)
                setError(null)
                const data = await getProjectById(id)
                if (!cancelled) setProject(data)
            } catch {
                if (!cancelled) setError('Projet introuvable.')
            } finally {
                if (!cancelled) setLoading(false)
            }
        }

        fetch()
        return () => { cancelled = true }
    }, [id])

    return { project, loading, error, setProject }
}