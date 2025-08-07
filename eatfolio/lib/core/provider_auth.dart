import 'package:flutter/material.dart';

// 로그인 상태 관리 Provider
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    print('AuthProvider.login() 시작 - 현재 상태: $_isLoggedIn');
    _isLoggedIn = true;
    print('AuthProvider.login() 완료 - 변경된 상태: $_isLoggedIn');
    notifyListeners();
    print('AuthProvider.notifyListeners() 호출됨');
  }

  void logout() {
    print('AuthProvider.logout() 시작 - 현재 상태: $_isLoggedIn');
    _isLoggedIn = false;
    print('AuthProvider.logout() 완료 - 변경된 상태: $_isLoggedIn');
    notifyListeners();
    print('AuthProvider.notifyListeners() 호출됨');
  }
}
