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
  @override
  void initState() {
    super.initState();
    // Fetch events when widget initializes
    Future.microtask(() => context.read<EventProvider>().fetchTodaysEvents());
  }

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
                      if (eventProvider.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (eventProvider.todaysEvents.isEmpty) {
                        return Center(
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
                        );
                      } else {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: eventProvider.todaysEvents.length,
                          itemBuilder: (context, index) {
                            final event = eventProvider.todaysEvents[index];
                            return TodayCard(
                              event: event,
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
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
                        "Registered events",
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
                      if (eventProvider.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (eventProvider.todaysEvents.isEmpty) {
                        return Center(
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
                                "You haven't registered for any event",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: eventProvider.todaysEvents.length,
                          itemBuilder: (context, index) {
                            final event = eventProvider.todaysEvents[index];
                            return TodayCard(
                              event: event,
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
