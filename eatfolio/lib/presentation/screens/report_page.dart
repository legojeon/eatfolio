import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/fonts.dart';
import '../../core/provider_auth.dart' as auth;
import '../../core/provider_nav.dart';
import '../widgets/buttons.dart';
import 'splash_page.dart';

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
            // Other content for the Report Page
            Expanded(
              child: Center(
                child: Text('Report Page Content', style: AppFonts.bodyMedium),
              ),
            ),

            // The moved Logout button
            SizedBox(height: 60),
            ButtonWide(
              text: 'LOGOUT',
              onPressed: () async {
                await context.read<auth.AuthProvider>().signOut();
                context.read<NavigationProvider>().setSelectedIndex(0);
                print('로그아웃 버튼 클릭됨');
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
