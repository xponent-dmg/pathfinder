import 'package:flutter/material.dart';
import 'package:path_finder/widgets/today_card.dart';

class Today extends StatelessWidget {
  const Today({super.key});

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
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_horiz),
                      color: Colors.grey[600],
                    )
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 330,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) => TodayCard(),
                  ),
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
