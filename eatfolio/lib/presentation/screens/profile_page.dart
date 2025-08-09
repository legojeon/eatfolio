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
    final String userEmail =
        context.watch<auth.AuthProvider>().currentUser?.email ?? 'User';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('eatfolio', style: AppFonts.logotext),
      ),
      extendBody: true,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 프로필 정보
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 32, color: Colors.grey[600]),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(userEmail, style: AppFonts.heading3),
                    const SizedBox(height: 6),
                    Text(
                      '먹은 음식 : $imageCount개',
                      style: AppFonts.caption.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            // 피드 이미지
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: GridView.builder(
                  padding: EdgeInsets.zero,
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
            ),
          ],
        ),
      ),
    );
  }
}
