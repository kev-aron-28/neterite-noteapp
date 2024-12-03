import 'package:flutter/material.dart';
import 'package:neterite/common/widgets/neterite_bottom_navigator.dart';
import 'package:neterite/features/Todo/models/todo_model.dart';
import 'package:neterite/features/Todo/repo/todo_repo.dart';
import 'package:neterite/features/Todo/screens/todo_new_screen.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  DateTime _selectedDay = DateTime.now();

  // Instancia del repositorio
  final InMemoryTodoRepository _repository = InMemoryTodoRepository();

  // Obtener tareas para un día específico
  List<TodoModel> _getTasksForDay(DateTime day) {
  final tasks = _repository.getAll(); // Assuming getAll() returns List<TodoModel>
  
  return tasks.where((task) {
    return task.date.year == day.year &&
           task.date.month == day.month &&
           task.date.day == day.day;
  }).toList();
}


  // Eliminar una tarea
  void _deleteTask(TodoModel task) {
    setState(() {
      _repository.delete(task.id);
    });
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

  @override
  Widget build(BuildContext context) {
    final todayTasks = _getTasksForDay(_selectedDay);
    final tomorrowTasks = _getTasksForDay(_selectedDay.add(const Duration(days: 1)));

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                child: const SearchBar(
                  leading: Icon(Icons.search),
                  hintText: "Buscar tarea",
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final day = _selectedDay.add(Duration(days: index - _selectedDay.weekday + 1));
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
                          ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'][day.weekday - 1],
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    _buildTaskList(todayTasks),
                    const SizedBox(height: 20),
                    Text(
                      'Tareas de mañana (${_selectedDay.add(const Duration(days: 1)).toLocal().toIso8601String().split("T").first}):',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    _buildTaskList(tomorrowTasks),
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
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
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
                  _deleteTask(task);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
