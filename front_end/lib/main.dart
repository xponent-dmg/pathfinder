import 'package:flutter/material.dart';
import 'package:path_finder/providers/event_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './app.dart';
import 'package:path_finder/providers/theme_provider.dart';
import './providers/user_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zttcqbheotutkxaqljvf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp0dGNxYmhlb3R1dGt4YXFsanZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMwNzQ4ODAsImV4cCI6MjA1ODY1MDg4MH0._LikwV4TS1IXI76Jsz0El8P6rsFwL6LiGohiEt9Wexw',
  );

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
