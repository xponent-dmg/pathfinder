// import 'package:dart_ipify/dart_ipify.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_finder/screens/home_page.dart';
import 'package:path_finder/screens/club_leader.dart';
import 'package:path_finder/screens/signin.dart';
import 'package:path_finder/screens/signup.dart';
import 'package:path_finder/screens/start_page.dart';
import './services/token_service.dart';
import './utils/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  token = await TokenService().getToken();
  ipaddr = await NetworkInfo().getWifiIP();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PathFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StartPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => App(),
        '/signin': (context) => SigninPage(),
        '/clubleader': (context) => ClubLeaderSignin(),
      },
    );
  }
}
