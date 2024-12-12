import 'package:neterite/features/Subject/model/subject_model.dart';
import 'package:neterite/features/Todo/models/todo_model.dart';

class InMemoryTodoRepository {
  // Hacemos que _tasks sea una propiedad privada de la clase.
  final Map<String, TodoModel> _tasks = {};

  // Singleton
  static final InMemoryTodoRepository _instance = InMemoryTodoRepository._internal();

  factory InMemoryTodoRepository() {
    return _instance;
  }

  InMemoryTodoRepository._internal(); // Constructor privado para el singleton

  // Crear una nueva tarea
  TodoModel create(TodoModel todo) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    todo.id = id;
    _tasks[id] = todo;
    return todo;
  }

  // Obtener todas las tareas
  List<TodoModel> getAll() {
    return _tasks.values.toList();
  }

  // Obtener una tarea específica
  TodoModel? getById(String id) {
    return _tasks[id];
  }

  // Actualizar una tarea
  bool update(String id, {String? title, bool? isCompleted, DateTime? date, String? subject}) {
    final task = _tasks[id];
    if (task != null) {
      if (title != null) {
        task.title = title;
      }
      if (isCompleted != null) {
        task.isCompleted = isCompleted;
      }
      if (date != null) {
        task.date = date;
      }

      if(subject != null) {
        task.subject = subject;
      }
      
      return true;
    }
    return false;
  }

  // Eliminar una tarea
  bool delete(String id) {
    return _tasks.remove(id) != null;
  }
}
