import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_finder/providers/event_provider.dart';
import 'package:path_finder/widgets/search_card.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final List<Map<String, dynamic>> filteredResults;
  const SearchScreen(
      {super.key, required this.fadeAnimation, required this.filteredResults});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Consumer<EventProvider>(builder: (context, eventProvider, child) {
        if (eventProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (eventProvider.eventList.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 70,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  "No events available",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Try refreshing or check back later",
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => eventProvider.fetchAllEvents(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                  ),
                  child: Text("Refresh"),
                ),
              ],
            ),
          );
        }

        if (filteredResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 70,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  "No results found",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Try different keywords or filters",
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: filteredResults.length,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemBuilder: (context, index) {
            final result = filteredResults[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SearchCard(event: result),
            );
          },
        );
      }),
    );
  }
}
