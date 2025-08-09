import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/fonts.dart';
import '../../core/provider_auth.dart' as auth;
import '../widgets/buttons.dart';
import 'profile_page.dart';
import '../../core/provider_nav.dart';
import 'splash_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userEmail =
        context.watch<auth.AuthProvider>().currentUser?.email ?? 'User';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('profile', style: AppFonts.heading3),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: Back(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 32, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(userEmail, style: AppFonts.heading3),
                    const SizedBox(height: 6),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: Container()),
            Logout(
              onPressed: () async {
                await context.read<auth.AuthProvider>().signOut();
                context.read<NavigationProvider>().setSelectedIndex(0);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SplashPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
