import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TicketPage extends StatelessWidget {
  const TicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final event = args['event'];
    final ticketNo = args['ticket_no'];

    return Scaffold(
      backgroundColor: Color.fromRGBO(182, 222, 255, 1),
      appBar: AppBar(
        title: Text('Your Ticket', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top part of ticket (Event Image & Name)
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    image: DecorationImage(
                      image: (event['pic'] != null)
                          ? NetworkImage(event['pic'])
                          : AssetImage('assets/event-pic.jpg') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['name'] ?? 'Unknown Event',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.blue.shade700),
                          SizedBox(width: 8),
                          Text(
                              "${event['date'] ?? ''} - ${event['time'] ?? ''}",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.red.shade400),
                          SizedBox(width: 8),
                          Text(
                              "${event['location'] ?? 'Online'} ${event['roomno'] ?? ''}",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Dashed line divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      final boxWidth = constraints.constrainWidth();
                      final dashWidth = 10.0;
                      final dashHeight = 2.0;
                      final dashCount = (boxWidth / (2 * dashWidth)).floor();
                      return Flex(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        direction: Axis.horizontal,
                        children: List.generate(dashCount, (_) {
                          return SizedBox(
                            width: dashWidth,
                            height: dashHeight,
                            child: DecoratedBox(
                              decoration:
                                  BoxDecoration(color: Colors.grey.shade400),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),

                // Bottom part of ticket (Barcode & Ticket No)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        "TICKET No.",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 2),
                      ),
                      SizedBox(height: 8),
                      Text(
                        ticketNo,
                        style: GoogleFonts.libreBarcode39(
                          fontSize: 48,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        ticketNo,
                        style: GoogleFonts.spaceMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Please show this ticket at the entrance.",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
