import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_finder/providers/event_provider.dart';
import 'package:path_finder/providers/user_provider.dart';
import 'package:path_finder/screens/event_create_page.dart';
import 'package:path_finder/screens/registered_events_page.dart';
import 'package:path_finder/screens/open_map_page.dart';
import 'package:path_finder/widgets/header.dart';
import 'package:path_finder/widgets/today.dart';
import 'widgets/bottom_navbar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isClubLeader = userProvider.role == 'clubleader';

    final List<Widget> screens = [
      RefreshIndicator(
        onRefresh: () async {
          final eventProvider = context.read<EventProvider>();
          final userProvider = context.read<UserProvider>();
          
          await Future.wait([
            eventProvider.fetchAllEvents(),
            eventProvider.fetchTodaysEvents(),
            if (userProvider.token.isNotEmpty)
              eventProvider.fetchRegisteredEvents(userProvider.token),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator to work with CustomScrollView
          slivers: [
            const Header(),
            const SliverToBoxAdapter(
              child: Today(),
            ),
          ],
        ),
      ),
      const OpenMapPage(),
      if (isClubLeader) const EventCreatePage(),
      const RegisteredEventsPage(),
    ];

    final int currentIndex = _selectedIndex.clamp(0, screens.length - 1);

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
          index: currentIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavbar(
          selectedIndex: currentIndex,
          onItemTapped: _onItemTapped,
          isClubLeader: isClubLeader,
        ),
      ),
    );
  }
}
