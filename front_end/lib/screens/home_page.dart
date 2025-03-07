import 'package:flutter/material.dart';
import 'package:path_finder/widgets/bottom_navbar.dart';
import 'package:path_finder/widgets/header.dart';
import 'package:path_finder/widgets/today.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Remove the nested MaterialApp and use just a Scaffold
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
