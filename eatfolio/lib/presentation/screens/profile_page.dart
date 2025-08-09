import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/fonts.dart';
import '../../core/provider_auth.dart' as auth;
import '../../core/provider_nav.dart';
import '../widgets/buttons.dart';
import 'splash_page.dart';
import '../widgets/cards.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - (24 * 2) - (8 * 2)) / 3;
    final int imageCount = 20; // 예시 이미지 개수

    return Scaffold(
      appBar: AppBar(title: Text('Profile Page', style: AppFonts.heading3)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 프로필 정보
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                ),
                SizedBox(width: 16),
                Text('User Name', style: AppFonts.heading2),
              ],
            ),
            SizedBox(height: 60),

            // 이미지 개수 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
                Text(
                  '$imageCount images',
                  style: AppFonts.bodySmall.copyWith(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),

            // 피드 이미지
            Expanded(
              child: GridView.builder(
                itemCount: imageCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemBuilder: (context, index) {
                  return ImageCard(width: cardWidth);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
