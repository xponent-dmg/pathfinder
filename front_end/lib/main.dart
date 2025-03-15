import 'package:flutter/material.dart';
import 'package:path_finder/screens/club_leader.dart';
import 'package:path_finder/screens/event_create_page.dart';
import 'package:path_finder/screens/event_details_page.dart';
import 'package:path_finder/screens/home_page.dart';
import 'package:path_finder/screens/profile_page.dart';
import 'package:path_finder/screens/signin.dart';
import 'package:path_finder/screens/signup.dart';
import 'package:path_finder/screens/start_page.dart';
import './providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/home',
      routes: {
        '/': (context) => const StartPage(),
        '/home': (context) => const HomePage(),
        '/signin': (context) => const SigninPage(),
        '/signup': (context) => const SignupPage(),
        '/profile': (context) => const ProfilePage(),
        '/clubleader': (context) => const ClubLeaderSignin(),
        '/event_details': (context) => const EventDetailsPage(),
        '/event_create': (context) => const EventCreatePage(),
      },
    );
  }
}
