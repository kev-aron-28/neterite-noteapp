import 'package:neterite/features/Todo/models/todo_model.dart';

class Subject {
  final String id;
  final String name;
  final String teacher;
  final List<TodoModel> todos;

  Subject({
    required this.id,
    required this.name,
    required this.teacher,
    this.todos = const []
  });
}
