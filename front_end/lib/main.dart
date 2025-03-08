import 'package:flutter/material.dart';
import 'package:path_finder/screens/event_details_page.dart';
import 'package:path_finder/screens/home_page.dart';
import 'package:path_finder/screens/profile_page.dart';
import 'package:path_finder/screens/signin.dart';
import 'package:path_finder/screens/signup.dart';
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
      initialRoute: '/signin',
      routes: {
        '/': (context) => const App(),
        '/home': (context) => const App(),
        '/signin': (context) => const SigninPage(),
        '/profile': (context) => const ProfilePage(),
        '/event_details': (context) => const EventDetailsPage(),
      },
    );
  }
}
