import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/provider_nav.dart';
import 'core/provider_auth.dart';
import 'presentation/widgets/nav_bar.dart' as nav;
import 'presentation/screens/splash_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'Eatfolio',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('AuthWrapper - 현재 로그인 상태: ${authProvider.isLoggedIn}');
        if (authProvider.isLoggedIn) {
          print('AuthWrapper - MainScreen으로 이동');
          return MainScreen();
        } else {
          print('AuthWrapper - SplashPage 표시');
          return SplashPage();
        }
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          appBar: null,
          body: navigationProvider.getCurrentPage(),
          // 조건부로 네비게이션 바 표시
          bottomNavigationBar: navigationProvider.shouldShowNavigationBar()
              ? nav.Tab()
              : null,
        );
      },
    );
  }
}
