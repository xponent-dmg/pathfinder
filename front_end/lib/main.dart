import 'package:flutter/material.dart';
import 'package:path_finder/providers/event_provider.dart';
import './app.dart';
import 'package:path_finder/providers/theme_provider.dart';
import './providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => EventProvider()),
      ],
      child: App(),
    ),
  );
}
