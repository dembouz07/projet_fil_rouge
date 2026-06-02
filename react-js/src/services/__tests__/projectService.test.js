import { getAllProjects, getProjectById, addProject, updateProject, deleteProject } from '../projectService';

// Mock de fetch
global.fetch = jest.fn();

describe('Project Service', () => {
  beforeEach(() => {
    fetch.mockClear();
  });

  describe('getAllProjects', () => {
    it('devrait récupérer tous les projets', async () => {
      const mockProjects = [
        { _id: '1', title: 'Projet 1' },
        { _id: '2', title: 'Projet 2' }
      ];

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true, data: mockProjects })
      });

      const result = await getAllProjects();

      expect(fetch).toHaveBeenCalledWith(expect.stringContaining('/api/projects'));
      expect(result).toHaveLength(2);
      expect(result[0]).toHaveProperty('id', '1');
      expect(result[0]).toHaveProperty('title', 'Projet 1');
    });

    it('devrait gérer les erreurs', async () => {
      fetch.mockResolvedValueOnce({
        ok: false,
        status: 500
      });

      await expect(getAllProjects()).rejects.toThrow();
    });
  });

  describe('getProjectById', () => {
    it('devrait récupérer un projet par son ID', async () => {
      const mockProject = { _id: '1', title: 'Projet 1' };

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true, data: mockProject })
      });

      const result = await getProjectById('1');

      expect(fetch).toHaveBeenCalledWith(expect.stringContaining('/api/projects/1'));
      expect(result).toHaveProperty('id', '1');
      expect(result).toHaveProperty('title', 'Projet 1');
    });

    it('devrait gérer les erreurs pour un projet inexistant', async () => {
      fetch.mockResolvedValueOnce({
        ok: false,
        status: 404
      });

      await expect(getProjectById('999')).rejects.toThrow();
    });
  });

  describe('addProject', () => {
    it('devrait créer un nouveau projet', async () => {
      const newProject = { title: 'Nouveau Projet', description: 'Description' };
      const mockResponse = { _id: '1', ...newProject };

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true, data: mockResponse })
      });

      const result = await addProject(newProject);

      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/projects'),
        expect.objectContaining({
          method: 'POST',
          headers: { 'Content-Type': 'application/json' }
        })
      );
      expect(result).toHaveProperty('id', '1');
      expect(result).toHaveProperty('title', 'Nouveau Projet');
    });

    it('devrait convertir les technologies en tableau', async () => {
      const newProject = { 
        title: 'Projet', 
        description: 'Description',
        technologies: 'React, Node.js, MongoDB'
      };
      const mockResponse = { _id: '1', ...newProject };

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true, data: mockResponse })
      });

      await addProject(newProject);

      const callArgs = fetch.mock.calls[0][1];
      const body = JSON.parse(callArgs.body);
      expect(body.technologies).toEqual(['React', 'Node.js', 'MongoDB']);
    });
  });

  describe('updateProject', () => {
    it('devrait mettre à jour un projet existant', async () => {
      const updatedData = { title: 'Projet Modifié' };
      const mockResponse = { _id: '1', ...updatedData };

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true, data: mockResponse })
      });

      const result = await updateProject('1', updatedData);

      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/projects/1'),
        expect.objectContaining({
          method: 'PUT'
        })
      );
      expect(result).toHaveProperty('id', '1');
      expect(result).toHaveProperty('title', 'Projet Modifié');
    });

    it('devrait gérer les erreurs de mise à jour', async () => {
      fetch.mockResolvedValueOnce({
        ok: false,
        status: 404,
        json: async () => ({ message: 'Projet introuvable' })
      });

      await expect(updateProject('999', { title: 'Test' })).rejects.toThrow();
    });
  });

  describe('deleteProject', () => {
    it('devrait supprimer un projet', async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true, message: 'Projet supprimé avec succès' })
      });

      await deleteProject('1');

      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining('/api/projects/1'),
        expect.objectContaining({
          method: 'DELETE'
        })
      );
    });

    it('devrait gérer les erreurs de suppression', async () => {
      fetch.mockResolvedValueOnce({
        ok: false,
        status: 404,
        json: async () => ({ message: 'Projet introuvable' })
      });

      await expect(deleteProject('999')).rejects.toThrow();
    });
  });
});
