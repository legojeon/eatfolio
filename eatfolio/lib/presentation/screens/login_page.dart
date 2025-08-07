import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';
import '../../core/provider_auth.dart';
import '../../main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // eatfolio 로고
              Center(child: Text('eatfolio', style: AppFonts.logotext)),
              SizedBox(height: 40),

              // 제목
              Text(
                'Log In',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontFamily: 'Sen',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20),
              // 이메일 입력 필드
              Text(
                'EMAIL',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontFamily: 'Sen',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'example@gmail.com',
                  style: TextStyle(
                    color: AppColors.inputText,
                    fontSize: 14,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 24),

              // 비밀번호 입력 필드
              Text(
                'PASSWORD',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontFamily: 'Sen',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '**********',
                  style: TextStyle(
                    color: AppColors.inputText,
                    fontSize: 14,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 6.72,
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Remember me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remember me',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'Forgot Password',
                    style: TextStyle(
                      color: AppColors.textLink,
                      fontSize: 14,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),

              // 로그인 버튼
              GestureDetector(
                onTap: () {
                  // 로그인 처리
                  print('로그인 버튼 클릭됨');
                  context.read<AuthProvider>().login();
                  print('AuthProvider.login() 호출됨');
                  // 로그인 성공 시 현재 화면을 MainScreen으로 교체
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 62,
                  decoration: ShapeDecoration(
                    color: AppColors.buttonPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'LOG IN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 14,
                        fontFamily: 'Sen',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Google 로그인 버튼
              GestureDetector(
                onTap: () {
                  // Google 로그인 처리
                  print('Google 로그인 버튼 클릭됨');
                  // TODO: Google 로그인 구현
                },
                child: Container(
                  width: double.infinity,
                  height: 62,
                  decoration: ShapeDecoration(
                    color: AppColors.buttonSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.borderMedium, width: 1),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.g_mobiledata,
                          color: AppColors.buttonSecondaryText,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Login with Google',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.buttonSecondaryText,
                            fontSize: 14,
                            fontFamily: 'Sen',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),

              // 회원가입 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDescription,
                      fontSize: 16,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'SIGN UP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textLink,
                      fontSize: 14,
                      fontFamily: 'Sen',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
