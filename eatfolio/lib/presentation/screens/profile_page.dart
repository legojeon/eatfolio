import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/fonts.dart';
import '../../core/provider_auth.dart' as auth;
import '../../core/provider_nav.dart';
import '../widgets/buttons.dart';
import '../../main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splash_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Page', style: AppFonts.heading3)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 프로필 정보 (예시)
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

            // 로그아웃 버튼
            ButtonWide(
              text: 'LOGOUT',
              onPressed: () async {
                // 로그아웃 처리
                await context.read<auth.AuthProvider>().signOut();
                // 네비게이션 인덱스도 0으로 리셋
                context.read<NavigationProvider>().setSelectedIndex(0);
                print('로그아웃 버튼 클릭됨');
                // 현재 화면을 AuthWrapper로 교체
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
