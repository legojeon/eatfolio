import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';
import '../../core/provider_auth.dart';
import '../../main.dart';
import 'login_page.dart';
import '../widgets/buttons.dart';
import 'splash_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
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
                  SizedBox(height: 20),
                  // 상단 영역 - Back 버튼과 제목
                  Row(
                    children: [
                      Back(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SplashPage(),
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Text('Sign Up', style: AppFonts.heading2),
                        ),
                      ),
                      // 오른쪽 공간을 위한 투명한 SizedBox
                      SizedBox(width: 45),
                    ],
                  ),
                  SizedBox(height: 20),

                  // 이름 입력 필드
                  Text('NAME', style: AppFonts.bodySmall),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
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
                        hintText: 'Enter your email',
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
                        hintText: 'Enter your password',
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

                  // 비밀번호 재입력 필드
                  Text('RE-TYPE PASSWORD', style: AppFonts.bodySmall),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _rePasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Re-enter your password',
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
                  SizedBox(height: 40),

                  // 회원가입 버튼
                  GestureDetector(
                    onTap: () async {
                      // 회원가입 처리
                      print('회원가입 버튼 클릭됨');
                      print('이름: ${_nameController.text}');
                      print('이메일: ${_emailController.text}');
                      print('비밀번호: ${_passwordController.text}');
                      print('비밀번호 재입력: ${_rePasswordController.text}');

                      // 입력 검증
                      if (_nameController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          _rePasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('모든 필드를 입력해주세요.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (_passwordController.text !=
                          _rePasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('비밀번호가 일치하지 않습니다.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      try {
                        // 실제 회원가입 로직
                        SignUpResult result = await context
                            .read<AuthProvider>()
                            .signUpWithEmailPassword(
                              _emailController.text,
                              _passwordController.text,
                            );

                        if (result.success) {
                          // 회원가입 성공 시 로그인 페이지로 이동
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result.message),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        } else {
                          // 회원가입 실패 시 에러 메시지 표시
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
                          'SIGN UP',
                          textAlign: TextAlign.center,
                          style: AppFonts.buttonPrimary,
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
                              'Sign up with Google',
                              textAlign: TextAlign.center,
                              style: AppFonts.buttonSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
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
