import 'package:flutter/material.dart';
import '../../core/fonts.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Page', style: AppFonts.heading3),
      ),
      body: Center(
        child: Text('Report Page Content', style: AppFonts.bodyMedium),
      ),
    );
  }
}