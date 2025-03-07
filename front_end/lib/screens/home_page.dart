import 'package:flutter/material.dart';
import 'package:path_finder/widgets/bottom_navbar.dart';
import 'package:path_finder/widgets/header.dart';
import 'package:path_finder/widgets/today.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(fontSize: 16),
          bodySmall: TextStyle(fontSize: 14),
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      title: 'My App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            Header(),
            SliverToBoxAdapter(
              child: Today(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavbar(),
      ),
    );
  }
}
