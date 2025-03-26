import 'package:flutter/material.dart';
import '../services/api_services/events_api.dart';

class EventProvider with ChangeNotifier {
  List<Map<String, dynamic>> _eventList = [];
  List<Map<String, dynamic>> _todaysEvents = [];
  bool _isLoading = false;
  String? _errorMessage;

  final EventsService _eventsService = EventsService();

  // Getters
  List<Map<String, dynamic>> get eventList => _eventList;
  List<Map<String, dynamic>> get todaysEvents => _todaysEvents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all events
  Future<void> fetchAllEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print("Fetching all events...");
      _eventList = await _eventsService.getAllEvents();
      print("Successfully fetched ${_eventList.length} events.");
    } catch (error) {
      _errorMessage = "Failed to load events: $error";
      print("Error fetching events: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch today's events
  Future<void> fetchTodaysEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print("Fetching today's events...");
      _todaysEvents = await _eventsService.todaysEvents();
      print("Successfully fetched ${_todaysEvents.length} today's events.");
    } catch (error) {
      _errorMessage = "Failed to load today's events: $error";
      print("Error fetching today's events: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
