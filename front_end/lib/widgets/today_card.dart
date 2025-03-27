import 'package:flutter/material.dart';

class TodayCard extends StatelessWidget {
  final Map<String, dynamic> event;
  const TodayCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/event_page');
      },
      child: Stack(
        children: [
          Container(
              width: 230,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              margin: EdgeInsets.only(right: 25, top: 5, bottom: 5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[300]!,
                      offset: Offset(1, 2),
                      blurRadius: 1,
                      spreadRadius: 1,
                    )
                  ]),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event["time"] ?? "time",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[800],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            event["day"] ?? "someday",
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            // event["date"] ?? "00-00-00",
                            event["clubName"] ?? "NaN",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: (event["pic"] != null)
                            ? Image.network(
                                event['pic'],
                                width: double.infinity,
                                height: 129,
                                fit: BoxFit.cover,
                              )
                            : Image.asset('assets/event-pic.jpg'),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      event["name"],
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      event["desc"],
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              )),
          Positioned(
              top: 20,
              child: Container(
                width: 3,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.orangeAccent,
                ),
              )),
          Positioned(
              top: 178,
              left: 18,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  event["profile-pic"] ?? "assets/profile_pics/profile-pic.jpg",
                  width: 40,
                ),
              ))
        ],
      ),
    );
  }
}
