import 'package:flutter/material.dart';
import 'package:path_finder/providers/event_provider.dart';
import 'package:path_finder/widgets/today_card.dart';
import 'package:provider/provider.dart';
import 'package:path_finder/providers/user_provider.dart';

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
    Future.microtask(() {
      context.read<EventProvider>().fetchTodaysEvents();
      final userToken = context.read<UserProvider>().token;
      if (userToken.isNotEmpty) {
        context.read<EventProvider>().fetchRegisteredEvents(userToken);
      }
    });
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
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Today's events",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 330,
                  child: Consumer<EventProvider>(
                    builder: (context, eventProvider, child) {
                      if (eventProvider.isLoading) {
                        return const Center(
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
                              const SizedBox(height: 16),
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
        ],
      ),
    );
  }
}
