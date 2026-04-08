import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:path_finder/providers/user_provider.dart';
import 'package:path_finder/services/supabase_service.dart';

class RegisteredEventsPage extends StatefulWidget {
  const RegisteredEventsPage({super.key});

  @override
  State<RegisteredEventsPage> createState() => _RegisteredEventsPageState();
}

class _RegisteredEventsPageState extends State<RegisteredEventsPage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _upcomingEvents = [];
  List<Map<String, dynamic>> _pastEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRegisteredEvents();
  }

  Future<void> _fetchRegisteredEvents() async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.token.isNotEmpty) {
      final events =
          await _supabaseService.getRegisteredEvents(userProvider.token);

      final now = DateTime.now();
      final upcoming = <Map<String, dynamic>>[];
      final past = <Map<String, dynamic>>[];

      for (var event in events) {
        final startTimeStr = event['start_time'];
        if (startTimeStr != null) {
          final startTime = DateTime.parse(startTimeStr).toLocal();
          if (startTime.isAfter(now)) {
            upcoming.add(event);
          } else {
            past.add(event);
          }
        } else {
          upcoming.add(event); // Default to upcoming if no date
        }
      }

      // Sort upcoming events by date (closest first)
      upcoming.sort((a, b) {
        final dateA = a['start_time'] != null ? DateTime.parse(a['start_time']) : DateTime.now();
        final dateB = b['start_time'] != null ? DateTime.parse(b['start_time']) : DateTime.now();
        return dateA.compareTo(dateB);
      });

      // Sort past events by date (most recent first)
      past.sort((a, b) {
        final dateA = a['start_time'] != null ? DateTime.parse(a['start_time']) : DateTime.now();
        final dateB = b['start_time'] != null ? DateTime.parse(b['start_time']) : DateTime.now();
        return dateB.compareTo(dateA);
      });

      setState(() {
        _upcomingEvents = upcoming;
        _pastEvents = past;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "My Events",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_upcomingEvents.isEmpty && _pastEvents.isEmpty)
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchRegisteredEvents,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      if (_upcomingEvents.isNotEmpty) ...[
                        Text(
                          "Upcoming Events",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._upcomingEvents
                            .map((event) => _buildEventCard(event))
                            .toList(),
                      ],
                      if (_pastEvents.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: Text(
                              "Past Events",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            children: _pastEvents
                                .map((event) => _buildEventCard(event, isPast: true))
                                .toList(),
                          ),
                        ),
                      ],
                      if (_upcomingEvents.isEmpty && _pastEvents.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              "No upcoming events.\nCheck your past events below.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, {bool isPast = false}) {
    // Basic mapping for the card display if needed
    final name = event['name'] ?? 'Unknown Event';
    final pic = event['image_url'];
    final building =
        event['buildings'] != null ? event['buildings']['name'] : 'Online';

    return Card(
      elevation: isPast ? 1 : 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Map event to what TicketPage expects
          final processedEvent = _supabaseService.processSingleEvent(event);
          Navigator.pushNamed(
            context,
            '/ticket',
            arguments: {
              'event': processedEvent,
              'ticket_no': event['ticket_no'] ?? 'N/A',
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: ColorFiltered(
                    colorFilter: isPast
                        ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                        : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                    child: pic != null
                        ? Image.network(
                            pic,
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/event-pic.jpg',
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/event-pic.jpg',
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPast ? Colors.grey[600] : Colors.blue[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPast ? "Past Event" : "Registered",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isPast ? Colors.grey[700] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(event['start_time']),
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          building ?? "Online",
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Tap to view ticket",
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.blue[700],
                      ),
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

  String _formatDate(String? startTime) {
    if (startTime == null) return "TBD";
    try {
      final date = DateTime.parse(startTime).toLocal();
      return "${date.day} ${_getMonth(date.month)}, ${date.year}";
    } catch (e) {
      return "TBD";
    }
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_note,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            "No registered events",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              "You haven't registered for any events yet. Explore events and sign up!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to explore
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text("Explore Events"),
          ),
        ],
      ),
    );
  }
}
