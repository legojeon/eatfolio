import 'package:flutter/material.dart';
import '../widgets/buttons.dart';
import '../../core/fonts.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // 각 버튼의 선택 상태를 개별적으로 관리
  Map<String, bool> ovalButtonStates = {
    'Delivery': false,
    'Pickup': false,
    'Dine-in': false,
    'Very Long Text Here': false,
  };
  
  Map<String, bool> circleButtonStates = {
    '\$\$\$': false,
    '\$\$': false,
    '\$': false,
    'A': false,
    'B': false,
  };
  
  int starRating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Page', style: AppFonts.heading3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Oval Buttons',
              style: AppFonts.heading3,
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OvalButton(
                  text: 'Delivery',
                  isSelected: ovalButtonStates['Delivery'] ?? false,
                  onPressed: () {
                    setState(() {
                      ovalButtonStates['Delivery'] = !(ovalButtonStates['Delivery'] ?? false);
                    });
                    print('Delivery tapped');
                  },
                ),
                OvalButton(
                  text: 'Pickup',
                  isSelected: ovalButtonStates['Pickup'] ?? false,
                  onPressed: () {
                    setState(() {
                      ovalButtonStates['Pickup'] = !(ovalButtonStates['Pickup'] ?? false);
                    });
                    print('Pickup tapped');
                  },
                ),
                OvalButton(
                  text: 'Dine-in',
                  isSelected: ovalButtonStates['Dine-in'] ?? false,
                  onPressed: () {
                    setState(() {
                      ovalButtonStates['Dine-in'] = !(ovalButtonStates['Dine-in'] ?? false);
                    });
                    print('Dine-in tapped');
                  },
                ),
                OvalButton(
                  text: 'Very Long Text Here',
                  isSelected: ovalButtonStates['Very Long Text Here'] ?? false,
                  onPressed: () {
                    setState(() {
                      ovalButtonStates['Very Long Text Here'] = !(ovalButtonStates['Very Long Text Here'] ?? false);
                    });
                    print('Long text tapped');
                  },
                ),
              ],
            ),
            SizedBox(height: 32),
            Text(
              'Circle Buttons',
              style: AppFonts.heading3,
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CircleButton(
                  text: '\$\$\$',
                  isSelected: circleButtonStates['\$\$\$'] ?? false,
                  onPressed: () {
                    setState(() {
                      circleButtonStates['\$\$\$'] = !(circleButtonStates['\$\$\$'] ?? false);
                    });
                    print('\$\$\$ tapped');
                  },
                ),
                CircleButton(
                  text: '\$\$',
                  isSelected: circleButtonStates['\$\$'] ?? false,
                  onPressed: () {
                    setState(() {
                      circleButtonStates['\$\$'] = !(circleButtonStates['\$\$'] ?? false);
                    });
                    print('\$\$ tapped');
                  },
                ),
                CircleButton(
                  text: '\$',
                  isSelected: circleButtonStates['\$'] ?? false,
                  onPressed: () {
                    setState(() {
                      circleButtonStates['\$'] = !(circleButtonStates['\$'] ?? false);
                    });
                    print('\$ tapped');
                  },
                ),
                CircleButton(
                  text: 'A',
                  isSelected: circleButtonStates['A'] ?? false,
                  onPressed: () {
                    setState(() {
                      circleButtonStates['A'] = !(circleButtonStates['A'] ?? false);
                    });
                    print('A tapped');
                  },
                ),
                CircleButton(
                  text: 'B',
                  isSelected: circleButtonStates['B'] ?? false,
                  onPressed: () {
                    setState(() {
                      circleButtonStates['B'] = !(circleButtonStates['B'] ?? false);
                    });
                    print('B tapped');
                  },
                ),
              ],
            ),
            SizedBox(height: 32),
            Text(
              'Star Rating',
              style: AppFonts.heading3,
            ),
            SizedBox(height: 16),
            StarRatingButton(
              rating: starRating,
              onRatingChanged: (rating) {
                setState(() {
                  starRating = rating;
                });
                print('Star rating changed to: $rating');
              },
            ),
            SizedBox(height: 16),
            Text(
              'Current Rating: $starRating/5',
              style: AppFonts.bodyMedium.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}