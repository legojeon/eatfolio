import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 회원가입 결과를 위한 클래스
class SignUpResult {
  final bool success;
  final String message;

  SignUpResult(this.success, this.message);
}

// 로그인 결과를 위한 클래스
class SignInResult {
  final bool success;
  final String message;

  SignInResult(this.success, this.message);
}

// 로그인 상태 관리 Provider
class AuthProvider extends ChangeNotifier {
  // Firebase Auth의 currentUser를 직접 사용
  User? get currentUser => FirebaseAuth.instance.currentUser;
  bool get isLoggedIn => currentUser != null;

  Future<void> signOut() async {
    print('AuthProvider.signOut() 시작 - 현재 상태: $isLoggedIn');
    await FirebaseAuth.instance.signOut();
    print('AuthProvider.signOut() 완료 - 변경된 상태: $isLoggedIn');
    notifyListeners();
    print('AuthProvider.notifyListeners() 호출됨');
  }

  Future<SignInResult> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // 로그인 성공 처리
      print('로그인 성공: ${userCredential.user?.email}');
      notifyListeners(); // 상태 변경 알림
      return SignInResult(true, '로그인이 완료되었습니다.');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = '등록되지 않은 이메일입니다.';
        print('등록되지 않은 이메일입니다.');
      } else if (e.code == 'wrong-password') {
        errorMessage = '잘못된 비밀번호입니다.';
        print('잘못된 비밀번호입니다.');
      } else if (e.code == 'invalid-email') {
        errorMessage = '올바르지 않은 이메일 형식입니다.';
        print('올바르지 않은 이메일 형식입니다.');
      } else if (e.code == 'invalid-credential') {
        errorMessage = '인증 정보가 올바르지 않습니다. 다시 시도해주세요.';
        print('인증 정보가 올바르지 않습니다: ${e.message}');
      } else {
        errorMessage = '로그인에 실패했습니다: ${e.message}';
        print('로그인 실패: ${e.message}');
      }
      return SignInResult(false, errorMessage);
    } catch (e) {
      String errorMessage = '알 수 없는 오류가 발생했습니다: $e';
      print(e.toString());
      return SignInResult(false, errorMessage);
    }
  }

  // 회원가입 함수
  Future<SignUpResult> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      // 회원가입 성공 처리
      print('회원가입 성공: ${userCredential.user?.email}');
      notifyListeners(); // 상태 변경 알림
      return SignUpResult(true, '회원가입이 완료되었습니다.');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = '비밀번호가 너무 약합니다. 더 강한 비밀번호를 사용해주세요.';
        print('비밀번호가 너무 약합니다.');
      } else if (e.code == 'email-already-in-use') {
        errorMessage = '이미 사용 중인 이메일입니다.';
        print('이미 사용 중인 이메일입니다.');
      } else if (e.code == 'invalid-email') {
        errorMessage = '올바르지 않은 이메일 형식입니다.';
        print('올바르지 않은 이메일 형식입니다.');
      } else {
        errorMessage = '회원가입에 실패했습니다: ${e.message}';
        print('회원가입 실패: ${e.message}');
      }
      return SignUpResult(false, errorMessage);
    } catch (e) {
      String errorMessage = '알 수 없는 오류가 발생했습니다: $e';
      print(e.toString());
      return SignUpResult(false, errorMessage);
    }
  }
}
