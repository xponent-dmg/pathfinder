import 'package:flutter/material.dart';
import 'package:path_finder/screens/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Remove the nested MaterialApp and use just a Scaffold
    return Scaffold(
      body: HomePage(),
    );
  }
}
