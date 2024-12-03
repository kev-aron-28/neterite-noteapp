import 'package:neterite/features/Calendar/model/event_model.dart';

class InMemoryEventRepository {
  // Lista que almacena los eventos en memoria
  final List<EventModel> _events = [];

  // Instancia privada del singleton
  static final InMemoryEventRepository _instance = InMemoryEventRepository._internal();

  // Constructor privado
  InMemoryEventRepository._internal();

  // Método estático para obtener la instancia única
  factory InMemoryEventRepository() {
    return _instance;
  }

  Future<void> createEvent(EventModel event) async {
    // Agregar un nuevo evento
    _events.add(event);
  }

  Future<List<EventModel>> getEvents() async {
    // Obtener todos los eventos
    return _events;
  }

  Future<void> updateEvent(EventModel event) async {
    // Buscar el índice del evento a actualizar
    final index = _events.indexWhere((existingEvent) => existingEvent.id == event.id);
    if (index != -1) {
      // Si se encuentra el evento, actualizarlo
      _events[index] = event;
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    // Eliminar un evento por su id
    _events.removeWhere((event) => event.id == id);
  }

  Future<List<EventModel>> getEventsForDay(DateTime day) async {
    // Filtrar los eventos que ocurren en el día específico
    return _events.where((event) {
      // Comparar solo el año, mes y día de la fecha para ignorar la hora
      return event.eventDate.year == day.year &&
             event.eventDate.month == day.month &&
             event.eventDate.day == day.day;
    }).toList();
  }
}
