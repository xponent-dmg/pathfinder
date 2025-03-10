import 'package:flutter/material.dart';
import 'package:path_finder/widgets/header.dart';
import 'package:path_finder/widgets/today.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const Header(),
        const SliverToBoxAdapter(
          child: Today(),
        ),
      ],
    );
  }
}
