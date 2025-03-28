import 'package:flutter/material.dart';
import 'package:path_finder/providers/event_provider.dart';
import 'package:path_finder/services/api_services/auth_det.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './app.dart';
import 'package:path_finder/providers/theme_provider.dart';
import './providers/user_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AuthDet().supaBaseUrl,
    anonKey: AuthDet().supaBaseAnon,
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
