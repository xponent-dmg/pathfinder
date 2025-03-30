import 'package:flutter/material.dart';
import 'package:path_finder/providers/event_provider.dart';
import 'package:path_finder/widgets/filter_overlay.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    // Initialize or fetch data if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      if (eventProvider.eventList.isEmpty) {
        eventProvider.fetchAllEvents();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterOverlay() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: const FilterOverlay(),
      ),
    );

    // After the filter overlay is closed, check if filters were applied
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    // Check if filters were applied by comparing filtered and full list lengths
    if (eventProvider.filteredEvents.length != eventProvider.eventList.length) {
      setState(() {
        _isFilterApplied = true;
      });
    }
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      // Reset to just show all events (no search or filter applied)
      Provider.of<EventProvider>(context, listen: false).resetFilters();
      setState(() {
        _isFilterApplied = false;
      });
    } else {
      // Apply search query
      Provider.of<EventProvider>(context, listen: false)
          .searchAndFilterEvents(query: query);
      setState(() {
        _isFilterApplied = true;
      });
    }
  }

  void _clearFilter() {
    _searchController.clear();
    Provider.of<EventProvider>(context, listen: false).resetFilters();
    setState(() {
      _isFilterApplied = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for events',
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: InputBorder.none,
              // Show clear button if search text or filters are applied,
              // otherwise show filter button
              suffixIcon: (_searchController.text.isNotEmpty ||
                      _isFilterApplied)
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                      onPressed: _clearFilter,
                    )
                  : IconButton(
                      icon: Icon(Icons.filter_list, color: Colors.blue[700]),
                      onPressed: _showFilterOverlay,
                    ),
            ),
            onChanged: _handleSearch,
          ),
        ),
        // Remove the additional filter icon from actions
        actions: [], // Empty to remove duplicate icon
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (eventProvider.filteredEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 70,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No events found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isFilterApplied || _searchController.text.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearFilter,
                      icon: Icon(Icons.refresh, color: Colors.blue[700]),
                      label: Text(
                        'Clear filters',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: eventProvider.filteredEvents.length,
            itemBuilder: (context, index) {
              final event = eventProvider.filteredEvents[index];
              return EventCard(event: event);
            },
          );
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/event_page', arguments: event);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: event["pic"] != null
                  ? Image.network(
                      event["pic"],
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/event-pic.jpg',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/event-pic.jpg',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),

            // Event details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event name
                  Text(
                    event["name"] ?? "Event Name",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location and time
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event["location"] != null
                              ? "${event['location']}${(event['roomno'] != null) ? (' - Room ' + event['roomno']) : ''}"
                              : "Location not specified",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${event["date"] ?? 'Date TBD'}, ${event["time"] ?? 'Time TBD'}",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  // Tags row
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (event["category"] != null)
                        _buildTag(event["category"], Colors.blue),
                      if (event["isMandatory"] == true)
                        _buildTag("Mandatory", Colors.red),
                      if (event["isOnline"] == true)
                        _buildTag("Online", Colors.green),
                      if (event["price"] != null && event["price"] > 0)
                        _buildTag("₹${event["price"]}", Colors.amber),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[300]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color[700],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
