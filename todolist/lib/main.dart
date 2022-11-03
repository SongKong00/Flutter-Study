import 'package:flutter/material.dart';
import 'package:todolist/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title:'ToDo List',
      home: SplashScreen(),
    );
  }
}


