import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool isFav = false;
  @override
  Widget build(BuildContext context) {
    final event =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      // Using transparent scaffold to maintain the design
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background with blur effect (lightened)
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: (event['pic'] != null)
                    ? NetworkImage(event['pic'])
                    : AssetImage('assets/event-pic.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.white
                    .withAlpha(230), // Changed to white with high opacity
              ),
            ),
          ),

          // Main content with scrolling
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Event Image with bottom border radius
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Image container
                      SizedBox(
                        height: 320,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                          child: event['pic'] != null
                              ? Image.network(
                                  event['pic'],
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/event-pic.jpg',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),

                      // Event details card positioned to overlap (lightened)
                      Positioned(
                        bottom: -60,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white, // Changed to white background
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(40),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['name'],
                                style: GoogleFonts.poppins(
                                  color: Colors.black, // Changed to black
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.black54,
                                      size: 16), // Changed to dark color
                                  SizedBox(width: 8),
                                  Text(
                                      "${event['date'] ?? "no date"} - ${event['time'] ?? "no time"}",
                                      style: TextStyle(
                                          color: Colors
                                              .black54)), // Changed to dark color
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      color: Colors.black54,
                                      size: 16), // Changed to dark color
                                  SizedBox(width: 8),
                                  Text(
                                      "${event['location'] ?? "no location"}, ${event['roomno'] ?? "no room"}",
                                      style: TextStyle(
                                          color: Colors
                                              .black54)), // Changed to dark color
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Space to accommodate the overlapping card
                  SizedBox(height: 70),

                  // Profile section in a card with blurred background (lightened)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white
                          .withAlpha(230), // Changed to light background
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(
                                    'assets/profile_pics/profile-pic.jpg'),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Zack Foster',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black, // Changed to black
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(event['clubName'] ?? "no clubname",
                                        style: TextStyle(
                                            color: Colors
                                                .black54)), // Changed to dark color
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue
                                      .shade600, // Changed to blue to match theme
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text('Follow',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Event details section (lightened)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Event',
                          style: GoogleFonts.poppins(
                            color: Colors.black, // Changed to black
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          event['desc'] ?? "no desc",
                          style: TextStyle(
                            color: Colors.black87, // Changed to dark color
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Location section with map (lightened)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: GoogleFonts.poppins(
                            color: Colors.black, // Changed to black
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        GestureDetector(
                          //arguments  can be handled later
                          onTap: () => Navigator.pushNamed(context, '/map',
                              arguments: event['location']),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: AssetImage("assets/maps_pic.webp"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'The Brooklyn Nightclub\n123 Main Street, Brooklyn, NY 11201',
                          style: TextStyle(
                            color: Colors.black87, // Changed to dark color
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Buy ticket button (color updated)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .blue.shade600, // Changed to blue to match theme
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: Text(
                        'Buy Ticket \$90',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Back button (lightened)
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color:
                    Colors.white.withAlpha(200), // Changed to white background
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Colors.black), // Changed icon to black
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Favorite button (lightened)
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color:
                    Colors.white.withAlpha(200), // Changed to white background
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.favorite_rounded,
                    color: (!isFav)
                        ? const Color.fromARGB(255, 89, 89, 89)
                        : Colors.red), // Changed icon to black
                onPressed: () {
                  setState(() {
                    isFav = !isFav;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
