import 'package:flutter/material.dart';
import 'package:path_finder/widgets/bottom_navbar.dart';
import 'package:path_finder/widgets/header.dart';
import 'package:path_finder/widgets/today.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          Header(),
          SliverToBoxAdapter(
            child: Today(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(),
    );
  }
}
