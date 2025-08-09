import 'package:flutter/material.dart';
import '../../core/fonts.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report Page', style: AppFonts.heading3)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text('Report Page Content', style: AppFonts.bodyMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
