import 'package:flutter/material.dart';
import '../../core/fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page', style: AppFonts.heading3),
      ),
      body: Center(
        child: Text('Profile Page Content', style: AppFonts.bodyMedium),
      ),
    );
  }
}