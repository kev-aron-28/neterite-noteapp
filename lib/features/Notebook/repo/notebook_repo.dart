import 'package:neterite/features/Notebook/models/canva_model.dart';

class InMemoryCanvasRepository {
  // Almacén interno
  final Map<String, CanvasModel> _storage = {};

  // Constructor privado
  InMemoryCanvasRepository._privateConstructor();

  // Instancia única
  static final InMemoryCanvasRepository _instance =
      InMemoryCanvasRepository._privateConstructor();

  // Getter para acceder a la instancia única
  factory InMemoryCanvasRepository() {
    return _instance;
  }

  // Crear un nuevo canvas
  void saveCanvas(CanvasModel canvas) {
    _storage[canvas.id] = canvas;
  }

  // Leer un canvas por su nombre
  CanvasModel? getCanvas(String id) {
    return _storage[id];
  }

  // Leer todos los canvas
  List<CanvasModel> getAllCanvas() {
    return _storage.values.toList();
  }

  // Actualizar un canvas existente
  void updateCanvas(String name, CanvasModel updatedCanvas) {
    _storage[name] = updatedCanvas;
  }

  // Eliminar un canvas por su nombre
  void deleteCanvas(String name) {
    if (_storage.containsKey(name)) {
      _storage.remove(name);
    } else {
      throw Exception('Canvas with name "$name" not found');
    }
  }

  // Vaciar el repositorio
  void clear() {
    _storage.clear();
  }
}
