import 'package:flutter/material.dart';

class TodayCard extends StatelessWidget {
  final String goto;
  const TodayCard({super.key, this.goto = '/event_page'});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Replace named route navigation with direct navigation
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
                        "18:30",
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
                            "friday",
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "july, 2019",
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
                        child: Image.asset("assets/event-pic.jpg"),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Rock Night",
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
                      "electrifying live performances, headbanging music, and an unforgettable rock atmosphere.",
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
                  "assets/profile-pic.jpg",
                  width: 40,
                ),
              ))
        ],
      ),
    );
  }
}
