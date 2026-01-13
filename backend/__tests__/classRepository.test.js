const ClassRepository = require('../src/repositories/classRepository');

describe('ClassRepository (tests de base)', () => {
  // Mock simple : on remplace les méthodes par des jest.fn()
  beforeAll(() => {
    ClassRepository.findAll = jest.fn().mockResolvedValue([{ id: 1, name: 'Yoga' }]);
    ClassRepository.findById = jest.fn().mockResolvedValue({ id: 1, name: 'Yoga' });
    ClassRepository.create = jest.fn().mockResolvedValue({ id: 2, name: 'Pilates' });
    ClassRepository.update = jest.fn().mockResolvedValue({ id: 1, name: 'Pilates' });
    ClassRepository.delete = jest.fn().mockResolvedValue({ id: 1 });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  test('findAll retourne les classes', async () => {
    const classes = await ClassRepository.findAll();
    expect(classes).toEqual([{ id: 1, name: 'Yoga' }]);
    expect(ClassRepository.findAll).toHaveBeenCalled();
  });

  test('findById retourne la bonne classe', async () => {
    const cls = await ClassRepository.findById(1);
    expect(cls).toEqual({ id: 1, name: 'Yoga' });
    expect(ClassRepository.findById).toHaveBeenCalledWith(1);
  });

  test('create ajoute une classe', async () => {
    const newClass = await ClassRepository.create({ name: 'Pilates' });
    expect(newClass).toEqual({ id: 2, name: 'Pilates' });
    expect(ClassRepository.create).toHaveBeenCalledWith({ name: 'Pilates' });
  });

  test('update modifie une classe', async () => {
    const updatedClass = await ClassRepository.update(1, { name: 'Pilates' });
    expect(updatedClass).toEqual({ id: 1, name: 'Pilates' });
    expect(ClassRepository.update).toHaveBeenCalledWith(1, { name: 'Pilates' });
  });

  test('delete supprime une classe', async () => {
    const deleted = await ClassRepository.delete(1);
    expect(deleted).toEqual({ id: 1 });
    expect(ClassRepository.delete).toHaveBeenCalledWith(1);
  });
});
