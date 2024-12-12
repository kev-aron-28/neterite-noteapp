import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importar intl para el formateo de fechas
import 'package:neterite/common/widgets/neterite_bottom_navigator.dart';
import 'package:neterite/features/Lobby/widgets/neterite_card_note.dart';
import 'package:neterite/features/Lobby/widgets/neterite_schedule_tile.dart';
import 'package:neterite/features/Lobby/widgets/neterite_todo_tile.dart';
import 'package:neterite/features/Calendar/repo/event_repo.dart'; // Importar el repositorio de eventos
import 'package:neterite/features/Calendar/model/event_model.dart'; // Importar el modelo de eventos
import 'package:neterite/features/Notebook/models/canva_model.dart';
import 'package:neterite/features/Notebook/repo/notebook_repo.dart';
import 'package:neterite/features/Todo/models/todo_model.dart';
import 'package:neterite/features/Todo/repo/todo_repo.dart'; // Importar el modelo de tareas

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late InMemoryEventRepository _eventRepository;
  late InMemoryTodoRepository _taskRepository;
  late InMemoryCanvasRepository canvasRepository = InMemoryCanvasRepository();
  List<EventModel> _todayEvents = [];
  List<TodoModel> _thisWeekTasks = [];
  List<CanvasModel> _canvas = [];

  @override
  void initState() {
    super.initState();
    _eventRepository = InMemoryEventRepository(); // Instanciamos el repositorio de eventos
    _taskRepository = InMemoryTodoRepository(); // Instanciamos el repositorio de tareas
    _loadData();
  }

  // Cargar los eventos de hoy y las tareas de esta semana
  Future<void> _loadData() async {
    // Obtener todos los eventos y tareas
    List<EventModel> allEvents = await _eventRepository.getEvents();
    List<TodoModel> allTasks = await _taskRepository.getAll();
    _canvas = canvasRepository.getAllCanvas();

    // Filtrar los eventos de hoy (asegurándote de que solo se obtienen los eventos de la fecha actual)
    DateTime now = DateTime.now();
    List<EventModel> events = allEvents.where((event) {
      DateTime eventDate = event.eventDate; // Suponiendo que el modelo de evento tiene una propiedad 'eventDate'
      return eventDate.year == now.year && eventDate.month == now.month && eventDate.day == now.day;
    }).toList();

    // Filtrar las tareas de esta semana
    List<TodoModel> tasks = allTasks.where((task) {
      DateTime taskDueDate = task.date; // Suponiendo que el modelo de tarea tiene una propiedad 'date'
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Primer día de la semana (lunes)
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6)); // Último día de la semana (domingo)

      return taskDueDate.isBefore(endOfWeek.add(Duration(days: 1))); // Tareas dentro de la semana
    }).toList();

    setState(() {
      _todayEvents = events;
      _thisWeekTasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Crear el formato de fecha
    var dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo en la parte superior centrado
              Center(
                child: Image.asset(
                  'assets/images/logo.png', // Ruta de la imagen
                  width: 130, // Tamaño del logo
                  height: 130, // Tamaño del logo
                ),
              ),
              const SizedBox(height: 25),

              // Últimas Notas Section
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "ULTIMAS NOTAS",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var note in _canvas)
                      NeteriteCardNote(noteTitle: note.name, noteId: note.id),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "HORARIO",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  const RotatedBox(
                    quarterTurns: 9, // Rotate "HOY" vertically
                    child: Text(
                      "HOY",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mostrar los eventos de hoy
                        for (var event in _todayEvents)
                          NeteriteScheduleTile(
                            title: event.title,
                            subtitle: dateFormat.format(event.eventDate), // Formatear la fecha del evento
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // TO DO Section
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "TO DO",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  const RotatedBox(
                    quarterTurns: 9, // Rotate "ESTA SEMANA" vertically
                    child: Text(
                      "ESTA SEMANA",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mostrar las tareas de esta semana
                        for (var task in _thisWeekTasks)
                          NeteriteTodoTile(
                            isChecked: task.isCompleted,
                            id: task.id,
                            title: task.title,
                            subtitle: dateFormat.format(task.date), // Formatear la fecha de la tarea
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NeteriteBottomNavigator(currentIndex: 2),
    );
  }
}
