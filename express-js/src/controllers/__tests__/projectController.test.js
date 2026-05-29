import { jest } from '@jest/globals';

// Mock du modèle Project AVANT l'import
const mockFind = jest.fn();
const mockFindById = jest.fn();
const mockCreate = jest.fn();
const mockFindByIdAndUpdate = jest.fn();
const mockFindByIdAndDelete = jest.fn();

jest.unstable_mockModule('../../models/Project.js', () => ({
  default: {
    find: mockFind,
    findById: mockFindById,
    create: mockCreate,
    findByIdAndUpdate: mockFindByIdAndUpdate,
    findByIdAndDelete: mockFindByIdAndDelete
  }
}));

// Import des modules APRÈS le mock
const { getAllProjects, getProjectById, createProject, updateProject, deleteProject } = 
  await import('../projectController.js');
const Project = (await import('../../models/Project.js')).default;

describe('Project Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      params: {},
      body: {}
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe('getAllProjects', () => {
    it('devrait retourner tous les projets', async () => {
      const mockProjects = [
        { _id: '1', title: 'Projet 1', description: 'Description 1' },
        { _id: '2', title: 'Projet 2', description: 'Description 2' }
      ];

      mockFind.mockReturnValue({
        sort: jest.fn().mockResolvedValue(mockProjects)
      });

      await getAllProjects(req, res, next);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        count: 2,
        data: mockProjects
      });
    });

    it('devrait gérer les erreurs', async () => {
      const error = new Error('Database error');
      mockFind.mockReturnValue({
        sort: jest.fn().mockRejectedValue(error)
      });

      await getAllProjects(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe('getProjectById', () => {
    it('devrait retourner un projet par son ID', async () => {
      const mockProject = { _id: '1', title: 'Projet 1', description: 'Description 1' };
      req.params.id = '1';

      mockFindById.mockResolvedValue(mockProject);

      await getProjectById(req, res, next);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        data: mockProject
      });
    });

    it('devrait retourner 404 si le projet n\'existe pas', async () => {
      req.params.id = '999';
      mockFindById.mockResolvedValue(null);

      await getProjectById(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Projet introuvable'
      });
    });
  });

  describe('createProject', () => {
    it('devrait créer un nouveau projet', async () => {
      const newProject = {
        title: 'Nouveau Projet',
        description: 'Description',
        technologies: ['React', 'Node.js']
      };
      req.body = newProject;

      const createdProject = { _id: '1', ...newProject };
      mockCreate.mockResolvedValue(createdProject);

      await createProject(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        message: 'Projet créé avec succès',
        data: createdProject
      });
    });

    it('devrait convertir les technologies en tableau si c\'est une chaîne', async () => {
      req.body = {
        title: 'Projet',
        description: 'Description',
        technologies: 'React, Node.js, MongoDB'
      };

      const createdProject = { _id: '1', ...req.body };
      mockCreate.mockResolvedValue(createdProject);

      await createProject(req, res, next);

      expect(req.body.technologies).toEqual(['React', 'Node.js', 'MongoDB']);
    });
  });

  describe('updateProject', () => {
    it('devrait mettre à jour un projet existant', async () => {
      const updatedData = {
        title: 'Projet Modifié',
        description: 'Nouvelle description'
      };
      req.params.id = '1';
      req.body = updatedData;

      const updatedProject = { _id: '1', ...updatedData };
      mockFindByIdAndUpdate.mockResolvedValue(updatedProject);

      await updateProject(req, res, next);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        message: 'Projet mis à jour avec succès',
        data: updatedProject
      });
    });

    it('devrait retourner 404 si le projet n\'existe pas', async () => {
      req.params.id = '999';
      req.body = { title: 'Test' };

      mockFindByIdAndUpdate.mockResolvedValue(null);

      await updateProject(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Projet introuvable'
      });
    });
  });

  describe('deleteProject', () => {
    it('devrait supprimer un projet existant', async () => {
      req.params.id = '1';
      const deletedProject = { _id: '1', title: 'Projet à supprimer' };

      mockFindByIdAndDelete.mockResolvedValue(deletedProject);

      await deleteProject(req, res, next);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        message: 'Projet supprimé avec succès',
        data: {}
      });
    });

    it('devrait retourner 404 si le projet n\'existe pas', async () => {
      req.params.id = '999';

      mockFindByIdAndDelete.mockResolvedValue(null);

      await deleteProject(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        message: 'Projet introuvable'
      });
    });
  });
});
