import 'package:flutter/material.dart';
import './app.dart';
import 'package:path_finder/providers/theme_provider.dart';
import './providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: App(),
    ),
  );
}
