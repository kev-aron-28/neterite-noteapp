import 'package:flutter/material.dart';
import 'package:neterite/common/widgets/neterite_bottom_navigator.dart';
import 'package:neterite/features/Calendar/repo/event_repo.dart';
import 'package:neterite/features/Calendar/screens/calendar_new_screen.dart';
import 'package:neterite/features/Calendar/model/event_model.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late InMemoryEventRepository _eventRepository;
  List<EventModel> _events = [];

  @override
  void initState() {
    super.initState();
    _eventRepository = InMemoryEventRepository();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    List<EventModel> events = await _eventRepository.getEventsForDay(_selectedDay);
    setState(() {
      _events = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayEvents = _events;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                child: const SearchBar(
                  leading: Icon(Icons.search),
                  hintText: "Buscar evento",
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Calendario
            TableCalendar(
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // Actualiza el enfoque del calendario
                });
                _loadEvents(); // Carga los eventos del día seleccionado
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Eventos del día seleccionado
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eventos de hoy (${_selectedDay.toLocal().toIso8601String().split("T").first}):',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    _buildEventList(todayEvents),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NeteriteBottomNavigator(currentIndex: 1),

      // Floating Action Button (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Redirige a la página de creación de evento
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Crear Evento',
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No hay eventos.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          leading: const Icon(Icons.event),
          title: Text(event.title), // Mostrar el título del evento
          subtitle: Text(event.description ?? "Sin descripción"), // Descripción del evento
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _deleteEvent(event);
            },
          ),
          onTap: () {
            _showEventDetails(event); // Mostrar más detalles del evento
          },
        );
      },
    );
  }

  void _deleteEvent(EventModel event) async {
    // Eliminar el evento (esto depende de la implementación del repositorio)
    await _eventRepository.deleteEvent(event.id);
    _loadEvents(); // Recargar los eventos
  }

  void _showEventDetails(EventModel event) {
    // Mostrar los detalles del evento en una pantalla nueva o como un modal
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Descripción: ${event.description ?? "Sin descripción"}"),
              const SizedBox(height: 10),
              Text("Fecha: ${event.eventDate}"),
              // Agregar más detalles según lo que desees mostrar
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
