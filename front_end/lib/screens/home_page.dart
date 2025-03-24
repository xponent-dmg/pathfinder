import 'package:flutter/material.dart';
import 'package:path_finder/screens/map_page.dart';
import 'package:path_finder/screens/event_create_page.dart';
import 'package:path_finder/screens/follow_page.dart';
import 'package:path_finder/screens/map_screen.dart';
import 'package:path_finder/widgets/header.dart';
import 'package:path_finder/widgets/today.dart';
import '../widgets/bottom_navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            // Home page
            CustomScrollView(
              slivers: [
                const Header(),
                const SliverToBoxAdapter(
                  child: Today(),
                ),
              ],
            ),
            // Explore page
            MapPage(),
            // Create Event page
            EventCreatePage(),
            // Follow page (previously search)
            FollowPage(),
          ],
        ),
        bottomNavigationBar: BottomNavbar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
