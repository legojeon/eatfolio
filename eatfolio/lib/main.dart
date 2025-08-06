import 'package:flutter/material.dart';
import 'presentation/screens/home_page.dart'; // Import your HomePage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eatfolio',
      home: HomePage(), // Set HomePage as the home widget
    );
  }
}
