import 'package:flutter/material.dart';
import 'package:path_finder/providers/event_provider.dart';
import 'package:path_finder/widgets/today_card.dart';
import 'package:provider/provider.dart';

class Today extends StatefulWidget {
  const Today({super.key});

  @override
  State<Today> createState() => _TodayState();
}

class _TodayState extends State<Today> {
  // final EventsService _eventsService = EventsService();
  List<Map<String, dynamic>> eventList = [];

  @override
  void initState() {
    super.initState();
    // Fetch events when widget initializes
    // getTodaysEvents();
    Future.microtask(() => context.read<EventProvider>().fetchTodaysEvents());
  }

  // Future<void> getTodaysEvents() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     var response = await EventsService.todaysEvents();
  //     setState(() {
  //       eventList = response;
  //       _isLoading = false;
  //     });
  //     print("Successfully fetched ${eventList.length} events");
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     print("Error occurred while fetching events: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Today's events",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Show a loading indicator when tapped
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Refreshing events..."),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        context.read<EventProvider>().fetchTodaysEvents();
                      },
                      child: Icon(Icons.refresh, color: Colors.blue[700]),
                    )
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 330,
                  child: Consumer<EventProvider>(
                      builder: (context, eventProvider, child) {
                    return (eventProvider.isLoading)
                        ? (eventProvider.eventList.isNotEmpty)
                            ? ListView.builder(
                                itemCount: eventProvider.eventList.length,
                                itemBuilder: (context, index) {
                                  final event = eventProvider.eventList[index];
                                  return TodayCard(
                                    event: event,
                                  );
                                },
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "No events for today",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                        : Center(
                            child: CircularProgressIndicator(),
                          );
                  }),
                ),
                // Add more scrollable content
                _buildScrollTestSection("Upcoming Events"),
                SizedBox(height: 20),
                _buildScrollTestSection("Popular Destinations"),
                SizedBox(height: 20),
                _buildScrollTestSection("Recommended For You"),
                SizedBox(height: 20),
                _buildScrollTestSection("Previous Visits"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScrollTestSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              "Scroll Test Content for $title",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
