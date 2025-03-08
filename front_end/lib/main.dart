import 'package:flutter/material.dart';
import 'package:path_finder/screens/club_leader.dart';
import 'package:path_finder/screens/event_create_page.dart';
import 'package:path_finder/screens/event_details_page.dart';
import 'package:path_finder/screens/home_page.dart';
import 'package:path_finder/screens/profile_page.dart';
import 'package:path_finder/screens/signin.dart';
import 'package:path_finder/screens/signup.dart';
import 'package:path_finder/screens/start_page.dart';
import './services/token_service.dart';
import './utils/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  token = await TokenService().getToken();
  runApp(const MyApp());
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
      initialRoute: '/',
      routes: {
        '/': (context) => const StartPage(),
        '/home': (context) => const App(),
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
