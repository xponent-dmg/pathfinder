import 'package:flutter/material.dart';
import 'package:path_finder/services/api_services/events_api.dart';

class EventProvider extends ChangeNotifier {
  final EventsService _eventsService = EventsService();

  List<Map<String, dynamic>> _eventList = [];
  List<Map<String, dynamic>> _todaysEvents = [];
  List<Map<String, dynamic>> _filteredEvents = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get eventList => _eventList;
  List<Map<String, dynamic>> get todaysEvents => _todaysEvents;
  List<Map<String, dynamic>> get filteredEvents => _filteredEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final events = await _eventsService.getAllEvents();
      _eventList = events;
      _filteredEvents = events; // Initialize filtered events with all events
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchAndFilterEvents({
    String? query,
    String? category,
    String? clubName,
    String? location,
    double? minPrice,
    double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
    bool? isMandatory,
    bool? isOnline,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('DEBUG: Starting searchAndFilterEvents with parameters:');
    print('DEBUG: query=$query, category=$category, clubName=$clubName');
    print('DEBUG: location=$location, price range=$minPrice-$maxPrice');
    print(
        'DEBUG: date range=${startDate?.toIso8601String()}-${endDate?.toIso8601String()}');
    print('DEBUG: isMandatory=$isMandatory, isOnline=$isOnline');

    // If we don't have any filters, just use the full event list we already have
    if ([
      query,
      category,
      clubName,
      location,
      minPrice,
      maxPrice,
      startDate,
      endDate,
      isMandatory,
      isOnline
    ].every((element) => element == null)) {
      print('DEBUG: No filters applied, using full event list');
      _filteredEvents = List.of(_eventList); // Create a copy of the full list
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // If we have _eventList populated, try filtering locally first for better performance
      // if (_eventList.isNotEmpty) {
      //   print('DEBUG: Using local filtering for better performance');
      _filteredEvents = await _eventsService.getAllEvents(
        query: query,
        category: category,
        clubName: clubName,
        location: location,
        minPrice: minPrice,
        maxPrice: maxPrice,
        startDate: startDate,
        endDate: endDate,
        isMandatory: isMandatory,
        isOnline: isOnline,
      );

      print('DEBUG: API returned ${_filteredEvents.length} events');
      // _filteredEvents = events;
      // _isLoading = false;
      notifyListeners();
      _filteredEvents = _eventList.where((event) {
        // Apply filters one by one, returning false as soon as any filter doesn't match

        // Text search (query)
        if (query != null && query.isNotEmpty) {
          final lowercaseQuery = query.toLowerCase();
          final name = event['name']?.toString().toLowerCase() ?? '';
          final desc = event['desc']?.toString().toLowerCase() ?? '';
          if (!name.contains(lowercaseQuery) &&
              !desc.contains(lowercaseQuery)) {
            return false;
          }
        }

        // Category filter
        if (category != null && category.isNotEmpty) {
          final eventCategory =
              event['category']?.toString().toLowerCase() ?? '';
          if (eventCategory != category.toLowerCase()) {
            return false;
          }
        }

        // Club name filter
        if (clubName != null && clubName.isNotEmpty) {
          final eventClubName =
              event['clubName']?.toString().toLowerCase() ?? '';
          if (!eventClubName.contains(clubName.toLowerCase())) {
            return false;
          }
        }

        // Location filter
        if (location != null && location.isNotEmpty) {
          final eventLocation = event['location'].toString().toLowerCase();
          if (!eventLocation.contains(location.toLowerCase())) {
            return false;
          }
        }

        // Price filter
        if (minPrice != null || maxPrice != null) {
          final eventPrice =
              double.tryParse(event['price']?.toString() ?? '0') ?? 0;

          if (minPrice != null && eventPrice < minPrice) {
            return false;
          }
          if (maxPrice != null && eventPrice > maxPrice) {
            return false;
          }
        }

        // Date filter
        if (startDate != null || endDate != null) {
          try {
            final eventDateStr = event['event_date'];
            if (eventDateStr != null) {
              final eventDate = DateTime.parse(eventDateStr);

              if (startDate != null && eventDate.isBefore(startDate)) {
                return false;
              }

              if (endDate != null) {
                // Add 1 day to end date to include the entire end date
                final adjustedEndDate = endDate.add(const Duration(days: 1));
                if (eventDate.isAfter(adjustedEndDate)) {
                  return false;
                }
              }
            } else {
              // If event has no date and filter includes date, exclude it
              if (startDate != null || endDate != null) {
                return false;
              }
            }
          } catch (e) {
            // If date parsing fails and filter includes date, exclude the event
            print('DEBUG: Error parsing event date: $e');
            if (startDate != null || endDate != null) {
              return false;
            }
          }
        }

        // Mandatory event filter
        if (isMandatory != null) {
          final isEventMandatory = event['isMandatory'] ?? false;
          if (isMandatory != isEventMandatory) {
            return false;
          }
        }

        // Online event filter
        if (isOnline != null) {
          final isEventOnline = event['isOnline'] ?? false;
          if (isOnline != isEventOnline) {
            return false;
          }
        }

        // If all filters passed, include this event
        return true;
      }).toList();

      print(
          'DEBUG: Local filtering complete - found ${_filteredEvents.length} matches out of ${_eventList.length} events');
      _isLoading = false;
      notifyListeners();
      // } else {
      //   // If we don't have _eventList populated, make an API call
      //   print('DEBUG: No cached events, calling API with filters');
    } catch (e) {
      print('DEBUG: ERROR in searchAndFilterEvents: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply filters locally if data is already loaded
  void applyLocalFilters({
    String? query,
    String? category,
    List<String>? categories,
    String? clubName,
    String? location,
    double? minPrice,
    double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
    bool? isMandatory,
    bool? isOnline,
  }) {
    print('DEBUG: Starting applyLocalFilters with parameters:');
    print('DEBUG: query=$query, category=$category');
    print('DEBUG: categories=$categories, clubName=$clubName');
    print('DEBUG: location=$location, price range=$minPrice-$maxPrice');
    print(
        'DEBUG: date range=${startDate?.toIso8601String()}-${endDate?.toIso8601String()}');
    print('DEBUG: isMandatory=$isMandatory, isOnline=$isOnline');

    if (_eventList.isEmpty) {
      print('DEBUG: Event list is empty, cannot apply filters');
      return;
    }

    print('DEBUG: Filtering ${_eventList.length} events');

    _filteredEvents = _eventList.where((event) {
      bool matchesFilters = true;

      print('DEBUG: ----------');
      print('DEBUG: Filtering event: ${event['name']}');
      print(
          'DEBUG: Event details: location=${event['location']}, roomno=${event['roomno']}');
      print(
          'DEBUG: Event category=${event['category']}, mandatory=${event['isMandatory']}, online=${event['isOnline']}');
      print('DEBUG: Event date=${event['event_date']}');

      // Text search across name and description
      if (query != null && query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        final nameMatches =
            event['name']?.toString().toLowerCase().contains(lowercaseQuery) ??
                false;
        final descMatches =
            event['desc']?.toString().toLowerCase().contains(lowercaseQuery) ??
                false;

        print(
            'DEBUG: Query filter: "$query" - name matches: $nameMatches, desc matches: $descMatches');

        if (!nameMatches && !descMatches) {
          matchesFilters = false;
          print('DEBUG: Query filter FAILED');
        }
      }

      // Single category filter
      if (category != null && category.isNotEmpty) {
        final eventCategory = event['category']?.toString().toLowerCase() ?? '';
        final matches = eventCategory == category.toLowerCase();

        print(
            'DEBUG: Category filter: "$category" vs "$eventCategory" - matches: $matches');

        if (!matches) {
          matchesFilters = false;
          print('DEBUG: Category filter FAILED');
        }
      }

      // Multiple categories filter (any match)
      if (categories != null && categories.isNotEmpty) {
        final eventCategory = event['category']?.toString().toLowerCase() ?? '';
        final categoryMatches = categories.any(
          (cat) => cat.toLowerCase() == eventCategory,
        );

        print(
            'DEBUG: Categories filter: $categories vs "$eventCategory" - matches: $categoryMatches');

        if (!categoryMatches) {
          matchesFilters = false;
          print('DEBUG: Categories filter FAILED');
        }
      }

      // Club name filter
      if (clubName != null && clubName.isNotEmpty) {
        final eventClubName = event['clubName']?.toString().toLowerCase() ?? '';
        final matches = eventClubName.contains(clubName.toLowerCase());

        print(
            'DEBUG: Club name filter: "$clubName" vs "$eventClubName" - matches: $matches');

        if (!matches) {
          matchesFilters = false;
          print('DEBUG: Club name filter FAILED');
        }
      }

      // Location filter
      if (location != null && location.isNotEmpty) {
        final eventLocation = event['location']?.toString().toLowerCase() ?? '';
        final roomNo = event['roomno']?.toString().toLowerCase() ?? '';
        final matches = eventLocation.contains(location.toLowerCase()) ||
            roomNo.contains(location.toLowerCase());

        print(
            'DEBUG: Location filter: "$location" vs loc:"$eventLocation"/room:"$roomNo" - matches: $matches');

        if (!matches) {
          matchesFilters = false;
          print('DEBUG: Location filter FAILED');
        }
      }

      // Price range filter
      if (minPrice != null || maxPrice != null) {
        final eventPrice =
            double.tryParse(event['price']?.toString() ?? '0') ?? 0;
        bool priceMatches = true;

        print('DEBUG: Price filter: $minPrice-$maxPrice vs $eventPrice');

        if (minPrice != null && eventPrice < minPrice) {
          priceMatches = false;
          print('DEBUG: Min price filter FAILED');
        }

        if (maxPrice != null && eventPrice > maxPrice) {
          priceMatches = false;
          print('DEBUG: Max price filter FAILED');
        }

        if (!priceMatches) {
          matchesFilters = false;
        }
      }

      // Date range filter
      if (startDate != null || endDate != null) {
        try {
          final eventDateStr = event['event_date'];
          print('DEBUG: Date filter: $startDate-$endDate vs $eventDateStr');

          if (eventDateStr != null) {
            final eventDate = DateTime.parse(eventDateStr);
            bool dateMatches = true;

            if (startDate != null && eventDate.isBefore(startDate)) {
              dateMatches = false;
              print('DEBUG: Start date filter FAILED');
            }

            if (endDate != null) {
              final adjustedEndDate = endDate.add(const Duration(days: 1));
              if (eventDate.isAfter(adjustedEndDate)) {
                dateMatches = false;
                print('DEBUG: End date filter FAILED');
              }
            }

            if (!dateMatches) {
              matchesFilters = false;
            }
          } else {
            // If no date is available and filter is set, don't include
            if (startDate != null || endDate != null) {
              matchesFilters = false;
              print('DEBUG: Date filter FAILED (event has no date)');
            }
          }
        } catch (e) {
          // If date parsing fails, don't include in results when filtering by date
          if (startDate != null || endDate != null) {
            matchesFilters = false;
            print('DEBUG: Date filter FAILED (parsing error: $e)');
          }
        }
      }

      // Mandatory events filter
      if (isMandatory != null) {
        final isEventMandatory = event['isMandatory'] ?? false;
        final matches = isMandatory == isEventMandatory;

        print(
            'DEBUG: Mandatory filter: $isMandatory vs $isEventMandatory - matches: $matches');

        if (!matches) {
          matchesFilters = false;
          print('DEBUG: Mandatory filter FAILED');
        }
      }

      // Online events filter
      if (isOnline != null) {
        final isEventOnline = event['isOnline'] ?? false;
        final matches = isOnline == isEventOnline;

        print(
            'DEBUG: Online filter: $isOnline vs $isEventOnline - matches: $matches');

        if (!matches) {
          matchesFilters = false;
          print('DEBUG: Online filter FAILED');
        }
      }

      print('DEBUG: Event final match result: $matchesFilters');
      return matchesFilters;
    }).toList();

    print('DEBUG: Filtered results count: ${_filteredEvents.length}');
    notifyListeners();
  }

  Future<void> fetchTodaysEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final events = await _eventsService.todaysEvents();

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

  // Get events by location
  List<Map<String, dynamic>> getEventsByLocation(String locationName) {
    return _eventList.where((event) {
      return (event['location']?.toString().toLowerCase() ==
              locationName.toLowerCase()) ||
          (event['roomNo']?.toString().toLowerCase() ==
              locationName.toLowerCase());
    }).toList();
  }

  // Reset filters
  void resetFilters() {
    print('DEBUG: Resetting filters, showing all ${_eventList.length} events');
    _filteredEvents = List.of(_eventList); // Create a copy of the full list
    notifyListeners();
  }
}
