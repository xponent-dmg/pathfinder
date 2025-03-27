import 'package:flutter/material.dart';
import 'package:path_finder/services/api_services/events_api.dart';

class EventProvider extends ChangeNotifier {
  final EventsService _eventsService = EventsService();

  List<Map<String, dynamic>> _eventList = [];
  List<Map<String, dynamic>> _todaysEvents = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get eventList => _eventList;
  List<Map<String, dynamic>> get todaysEvents => _todaysEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final events = await _eventsService.getAllEvents();
      _eventList = events;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTodaysEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final events = await _eventsService.getAllEvents();

      // Filter events for today
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      _todaysEvents = events.where((event) {
        // Parse the event date - assuming event_date is in ISO format
        if (event['event_date'] == null) return false;

        try {
          final eventDate = DateTime.parse(event['event_date']);
          final eventDateOnly =
              DateTime(eventDate.year, eventDate.month, eventDate.day);
          return eventDateOnly.isAtSameMomentAs(today);
        } catch (e) {
          print(
              'Error parsing date for event: ${event['name']} - ${e.toString()}');
          return false;
        }
      }).toList();

      // If today's events are empty, just use some of the most recent events as placeholder
      if (_todaysEvents.isEmpty && events.isNotEmpty) {
        _todaysEvents = events.take(3).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void addEvent(Map<String, dynamic> event) {
    _eventList.insert(0, event);
    notifyListeners();
  }
}
