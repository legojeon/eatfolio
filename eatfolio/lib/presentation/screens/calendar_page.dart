import 'package:flutter/material.dart';
import '../widgets/cards.dart';
import '../../core/fonts.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar Page', style: AppFonts.heading3)),
      body: Center(
        child: FoodCard(
          food: 'Chicken Thai Biriyani',
          time: 'Breakfast',
          category: '양식',
        ),
      ),
    );
  }
}
