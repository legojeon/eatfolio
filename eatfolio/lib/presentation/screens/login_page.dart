import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/constants.dart';
import '../../core/fonts.dart';
import '../../core/provider_auth.dart';
import '../../core/provider_nav.dart';
import '../../main.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // 키보드 숨기기
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  // eatfolio 로고
                  Center(child: Text('eatfolio', style: AppFonts.logotext)),
                  SizedBox(height: 40),

                  // 제목
                  Text('Log In', style: AppFonts.heading2),
                  SizedBox(height: 20),
                  // 이메일 입력 필드
                  Text('EMAIL', style: AppFonts.bodySmall),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'example@gmail.com',
                        hintStyle: AppFonts.bodySmall.copyWith(
                          color: AppColors.inputText,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // 비밀번호 입력 필드
                  Text('PASSWORD', style: AppFonts.bodySmall),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '**********',
                        hintStyle: AppFonts.bodySmall.copyWith(
                          color: AppColors.inputText,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 6.72,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w400,
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
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'Forgot Password',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.textLink,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),

                  // 로그인 버튼
                  GestureDetector(
                    onTap: () async {
                      // 로그인 처리
                      print('로그인 버튼 클릭됨');
                      print('이메일: ${_emailController.text}');
                      print('비밀번호: ${_passwordController.text}');

                      // 입력 검증
                      if (_emailController.text.isEmpty ||
                          _passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('이메일과 비밀번호를 입력해주세요.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      try {
                        // 실제 로그인 로직
                        SignInResult result = await context
                            .read<AuthProvider>()
                            .signInWithEmailPassword(
                              _emailController.text,
                              _passwordController.text,
                            );

                        if (result.success) {
                          // 탭 인덱스 초기화
                          context.read<NavigationProvider>().setSelectedIndex(
                            0,
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScreen(),
                            ),
                          );
                        } else {
                          // 로그인 실패 시 에러 메시지 표시
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        // 예외 발생 시 에러 메시지 표시
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('오류가 발생했습니다: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
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
                          style: AppFonts.buttonPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Google 로그인 버튼
                  GestureDetector(
                    onTap: () async {
                      // Google 로그인 처리
                      print('Google 로그인 버튼 클릭됨');
                      try {
                        firebase_auth.UserCredential? userCredential =
                            await context
                                .read<AuthProvider>()
                                .signInWithGoogle();

                        if (userCredential != null) {
                          // 로그인 성공! 홈 화면으로 이동
                          print(
                            '구글 로그인 성공: ${userCredential.user?.displayName}',
                          );
                          // 탭 인덱스 초기화
                          context.read<NavigationProvider>().setSelectedIndex(
                            0,
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScreen(),
                            ),
                          );
                        } else {
                          // 로그인 실패 또는 취소
                          print('구글 로그인이 취소되거나 실패했습니다.');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('구글 로그인이 취소되었습니다.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        // 예외 발생 시 에러 메시지 표시
                        print('구글 로그인 오류: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('구글 로그인 중 오류가 발생했습니다.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 62,
                      decoration: ShapeDecoration(
                        color: AppColors.buttonSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.borderMedium,
                            width: 1,
                          ),
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
                              style: AppFonts.buttonSecondary,
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
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.textDescription,
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupPage(),
                            ),
                          );
                        },
                        child: Text(
                          'SIGN UP',
                          textAlign: TextAlign.center,
                          style: AppFonts.buttonSmall.copyWith(
                            color: AppColors.textLink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
