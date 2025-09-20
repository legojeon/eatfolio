import 'package:flutter/material.dart';
import '../../core/fonts.dart';
import '../widgets/buttons.dart';
import 'login_page.dart';
import 'signup_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 상단 영역 - eatfolio 로고
              Expanded(
                child: Center(
                  child: Text('eatfolio', style: AppFonts.logotext),
                ),
              ),

              // 하단 영역 - 버튼들
              Column(
                children: [
                  // Login 버튼
                  ButtonWide(
                    text: 'LOGIN',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                  SizedBox(height: 16),

                  // Sign Up 버튼
                  ButtonWide(
                    text: 'SIGN UP',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
