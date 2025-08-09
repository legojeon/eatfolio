import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/fonts.dart';
import '../../core/provider_auth.dart' as auth;
import '../../core/provider_nav.dart';
import '../widgets/buttons.dart';
import 'splash_page.dart';
import '../widgets/cards.dart'; // Import ImageCard from cards.dart

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate the width for each ImageCard to fit 3 in a row with padding.
    // The total width is the screen width minus the horizontal padding (24 * 2) and the spacing between cards (8 * 2).
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - (24 * 2) - (8 * 2)) / 3;

    return Scaffold(
      appBar: AppBar(title: Text('Profile Page', style: AppFonts.heading3)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 프로필 정보
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('User Name', style: AppFonts.heading3),
                  SizedBox(height: 8),
                  Text(
                    'user@example.com',
                    style: AppFonts.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),

            // 피드
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 images per row
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemBuilder: (context, index) {
                  // Use ImageCard as the placeholder for each grid item
                  return ImageCard(width: cardWidth);
                },
              ),
            ),
            SizedBox(height: 60),

            // 로그아웃 버튼
            ButtonWide(
              text: 'LOGOUT',
              onPressed: () async {
                // 로그아웃 처리
                await context.read<auth.AuthProvider>().signOut();
                // 네비게이션 인덱스도 0으로 리셋
                context.read<NavigationProvider>().setSelectedIndex(0);
                print('로그아웃 버튼 클릭됨');
                // 현재 화면을 SplashPage로 교체
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SplashPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
