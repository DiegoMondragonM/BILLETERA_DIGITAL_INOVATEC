import 'package:flutter/material.dart';
import 'package:namer_app/Screens/login_screen.dart';
import 'package:namer_app/Screens/register_screen.dart';
import 'Screens/add_card_screen.dart';
//import 'screens/add_card_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen());
  }
}
