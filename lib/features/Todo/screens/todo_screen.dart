import 'package:flutter/material.dart';
import 'package:neterite/common/widgets/neterite_bottom_navigator.dart';
import 'package:neterite/features/Todo/models/todo_model.dart';
import 'package:neterite/features/Todo/repo/todo_repo.dart';
import 'package:neterite/features/Todo/screens/todo_new_screen.dart';
import 'package:neterite/features/Todo/screens/todo_update_screen.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  DateTime _selectedDay = DateTime.now();

  // Instancia del repositorio
  final InMemoryTodoRepository _repository = InMemoryTodoRepository();

  // Controlador para la barra de búsqueda
  final TextEditingController _searchController = TextEditingController();

  // Obtener tareas para un día específico
  List<TodoModel> _getTasksForDay(DateTime day) {
    final tasks =
        _repository.getAll(); // Assuming getAll() returns List<TodoModel>
    return tasks.where((task) {
      return task.date.year == day.year &&
          task.date.month == day.month &&
          task.date.day == day.day;
    }).toList();
  }

  // Confirmar eliminación de una tarea
  void _confirmDeleteTask(TodoModel task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Tarea'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar esta tarea? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _repository.delete(task.id);
                });
                Navigator.of(context)
                    .pop(); // Cierra el modal después de confirmar
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Cambiar la fecha de una tarea
  Future<void> _pickDate(TodoModel task) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: task.date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        // Actualizar la fecha en la tarea
        task.date = selectedDate;

        // Reasignar la tarea al nuevo día
        _repository.update(task.id, date: selectedDate);
      });
    }
  }

  // Filtrar tareas por título basado en la barra de búsqueda
  List<TodoModel> _filterTasks(List<TodoModel> tasks) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return tasks;
    }
    return tasks.where((task) {
      return task.title.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final todayTasks = _getTasksForDay(_selectedDay);
    final tomorrowTasks =
        _getTasksForDay(_selectedDay.add(const Duration(days: 1)));

    // Filtrar tareas por búsqueda
    final filteredTodayTasks = _filterTasks(todayTasks);
    final filteredTomorrowTasks = _filterTasks(tomorrowTasks);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Título de la pantalla
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                'Tareas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 15),
            // Barra de búsqueda,
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final day = _selectedDay
                    .add(Duration(days: index - _selectedDay.weekday + 1));
                final isSelected = _selectedDay.day == day.day;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = day;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          [
                            'Lun',
                            'Mar',
                            'Mié',
                            'Jue',
                            'Vie',
                            'Sáb',
                            'Dom'
                          ][day.weekday - 1],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          day.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tareas de hoy (${_selectedDay.toLocal().toIso8601String().split("T").first}):',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    _buildTaskList(filteredTodayTasks),
                    const SizedBox(height: 20),
                    Text(
                      'Tareas de mañana (${_selectedDay.add(const Duration(days: 1)).toLocal().toIso8601String().split("T").first}):',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    _buildTaskList(filteredTomorrowTasks),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NeteriteBottomNavigator(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ToDoCreateScreen(),
            ),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Construir la lista de tareas
  Widget _buildTaskList(List<TodoModel> tasks) {
    if (tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No hay tareas.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (bool? value) {
              setState(() {
                task.isCompleted = value ?? false;
                _repository.update(task.id, isCompleted: value);
              });
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateTodoScreen(id: task.id),
              ),
            );
          },
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text('Materia: ${task.subject ?? "No asignada"}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  _pickDate(task);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _confirmDeleteTask(task);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
