import 'package:flutter/material.dart';
import 'package:path_finder/screens/profile_page.dart';
import 'package:path_finder/widgets/bottom_navbar.dart';
import 'package:path_finder/screens/home_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    // Add other pages as needed for your bottom navbar
    const Center(child: Text('Explore')),
    const Center(child: Text('Events')),
    const ProfilePage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
      ),
    );
  }
}
