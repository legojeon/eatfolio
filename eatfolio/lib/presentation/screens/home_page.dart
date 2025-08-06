import 'package:flutter/material.dart';
import '../widgets/buttons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonWide(text: 'ADD TO CART'), // 기존 Button
            SizedBox(height: 20), // 버튼 사이 간격
            Back(), // Back 버튼 추가
          ],
        ),
      ),
    );
  }
}