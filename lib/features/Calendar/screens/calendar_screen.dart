import 'package:flutter/material.dart';
import 'package:neterite/common/widgets/neterite_bottom_navigator.dart';
import 'package:neterite/features/Calendar/repo/event_repo.dart';
import 'package:neterite/features/Calendar/screens/calendar_new_screen.dart';
import 'package:neterite/features/Calendar/model/event_model.dart';
import 'package:neterite/features/Calendar/screens/calendar_update_screen.dart';
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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _eventRepository = InMemoryEventRepository();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    List<EventModel> events = await _eventRepository.getEventsForDay(_selectedDay);
    if (_searchQuery.isNotEmpty) {
      events = events.where((event) =>
          event.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    setState(() {
      _events = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayEvents = _events;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                children: [
                  const Text(
                    'Calendario',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 15),
            TableCalendar(
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadEvents();
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
            Text(
              'Eventos de hoy (${_selectedDay.toLocal().toIso8601String().split("T").first}):',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: _buildEventList(todayEvents),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NeteriteBottomNavigator(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventPage()),
          );

          setState(() {
            _loadEvents();
          });
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
          title: Text(event.title),
          subtitle: Text(event.description ?? "Sin descripción"),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmationModal(event);
            },
          ),
          onTap: () {
            _showEventDetails(event);
          },
        );
      },
    );
  }

  void _showDeleteConfirmationModal(EventModel event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar el evento "${event.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteEvent(event);
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(EventModel event) async {
    await _eventRepository.deleteEvent(event.id);
    _loadEvents();
  }

  Future<void> _showEventDetails(EventModel event) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateEventView(eventId: event.id)));

    setState(() {
      _loadEvents();
    });
  }
}
