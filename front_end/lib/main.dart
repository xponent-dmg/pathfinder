import 'package:flutter/material.dart';
import 'package:path_finder/app.dart';
import 'package:path_finder/pages/club_leader.dart';
import 'package:path_finder/pages/signin.dart';
import 'package:path_finder/pages/signup.dart';
import 'package:path_finder/pages/start_page.dart';
// import 'package:path_finder/pages/testpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PathFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SigninPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => App(),
        '/signin': (context) => SigninPage(),
        '/clubleader': (context) => ClubLeaderSignin(),
      },
    );
  }
}
