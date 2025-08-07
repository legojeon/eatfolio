import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';
import '../../core/provider_auth.dart';
import '../../main.dart';
import 'login_page.dart';
import '../widgets/buttons.dart';
import 'splash_page.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

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
              // 상단 영역 - Back 버튼과 제목
              Row(
                children: [
                  Back(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SplashPage()),
                      );
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 30,
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // 오른쪽 공간을 위한 투명한 SizedBox
                  SizedBox(width: 45),
                ],
              ),
              SizedBox(height: 40),

              // 이름 입력 필드
              Text(
                'NAME',
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
                  'Enter your name',
                  style: TextStyle(
                    color: AppColors.inputText,
                    fontSize: 14,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 24),

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
                  'Enter your email',
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
                  'Enter your password',
                  style: TextStyle(
                    color: AppColors.inputText,
                    fontSize: 14,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 24),

              // 비밀번호 재입력 필드
              Text(
                'RE-TYPE PASSWORD',
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
                  'Re-enter your password',
                  style: TextStyle(
                    color: AppColors.inputText,
                    fontSize: 14,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 40),

              // 회원가입 버튼
              GestureDetector(
                onTap: () {
                  // 회원가입 처리
                  print('회원가입 버튼 클릭됨');
                  // TODO: 실제 회원가입 로직 구현
                  // 회원가입 성공 시 로그인 페이지로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
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
                      'SIGN UP',
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

              // Google 회원가입 버튼
              GestureDetector(
                onTap: () {
                  // Google 회원가입 처리
                  print('Google 회원가입 버튼 클릭됨');
                  // TODO: Google 회원가입 구현
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
                          'Sign up with Google',
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
            ],
          ),
        ),
      ),
    );
  }
}
