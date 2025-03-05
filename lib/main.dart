import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador Financiero', // Título de la app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Color principal
      ),
      //home: HomeScreen(), // Pantalla inicial
    );
  }
}
