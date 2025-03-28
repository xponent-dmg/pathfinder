import 'package:flutter/material.dart';
import 'package:path_finder/screens/club_leader.dart';
import 'package:path_finder/screens/map_page.dart';
import 'package:path_finder/screens/event_create_page.dart';
import 'package:path_finder/screens/home_page.dart';
import 'package:path_finder/screens/profile_page.dart';
import 'package:path_finder/screens/search_page.dart';
import 'package:path_finder/screens/signin.dart';
import 'package:path_finder/screens/signup.dart';
import 'package:path_finder/screens/start_page.dart';
import 'package:path_finder/screens/event_page.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PathFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // brightness: Brightness.light,
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // darkTheme: ThemeData(
      //   // brightness: Brightness.dark,
      //   fontFamily: 'Poppins',
      //   primarySwatch: Colors.blue,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),

      // themeMode: context.watch<ThemeProvider>().themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const StartPage(),
        '/home': (context) => const HomePage(),
        '/signin': (context) => const SigninPage(),
        '/signup': (context) => const SignupPage(),
        '/profile': (context) => const ProfilePage(),
        '/clubleader': (context) => const ClubLeaderSignin(),
        '/event_page': (context) => const EventPage(),
        '/event_create': (context) => const EventCreatePage(),
        '/map': (context) => const MapPage(),
        '/search': (context) => const SearchPage(),
      },
    );
  }
}
