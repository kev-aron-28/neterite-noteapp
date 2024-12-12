import 'package:flutter/material.dart';
import 'package:neterite/features/Todo/models/todo_model.dart';
import 'package:neterite/features/Todo/repo/todo_repo.dart';
import 'package:neterite/features/Subject/repo/subject_repo.dart';
import 'package:neterite/features/Subject/model/subject_model.dart';

class ToDoCreateScreen extends StatefulWidget {
  const ToDoCreateScreen({Key? key}) : super(key: key);

  @override
  _ToDoCreateScreenState createState() => _ToDoCreateScreenState();
}

class _ToDoCreateScreenState extends State<ToDoCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedSubjectId; // Variable to store the selected subject ID

  final InMemoryTodoRepository _todoRepository = InMemoryTodoRepository();
  final InMemorySubjectRepository _subjectRepository = InMemorySubjectRepository();

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  void _createTask() {
    if (_formKey.currentState!.validate()) {
      final taskTitle = _taskController.text;

      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una fecha')),
        );
        return;
      }

      if (_selectedSubjectId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una materia')),
        );
        return;
      }

      print(_selectedSubjectId);

      // Creating the task model to be saved
      final newTask = TodoModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),  // Generate a unique ID
        title: taskTitle,
        date: _selectedDate!,
        isCompleted: false,
        subject: _selectedSubjectId!, // Assign selected subject
      );

      // Save the task using the repository
      _todoRepository.create(newTask);

      // Feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea creada exitosamente')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Load the list of subjects from the repository
    final List<Subject> subjects = _subjectRepository.getAllSubjects();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Tarea'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo para ingresar el título de la tarea
              TextFormField(
                controller: _taskController,
                decoration: const InputDecoration(
                  labelText: 'Título de la Tarea',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Selector de fecha
              Row(
                children: [
                  Text(
                    _selectedDate == null
                        ? 'Selecciona una fecha'
                        : 'Fecha: ${_selectedDate!.toLocal().toIso8601String().split("T").first}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Elegir Fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dropdown para seleccionar la materia
              DropdownButtonFormField<String>(
                value: _selectedSubjectId,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubjectId = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Selecciona la Materia',
                  border: OutlineInputBorder(),
                ),
                items: subjects.map((Subject subject) {
                  return DropdownMenuItem<String>(
                    value: subject.name,
                    child: Text(subject.name),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona una materia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Botón para crear tarea
              Center(
                child: ElevatedButton(
                  onPressed: _createTask,
                  child: const Text('Crear Tarea'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}
