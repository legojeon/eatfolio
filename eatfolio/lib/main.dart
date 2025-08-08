import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/provider_auth.dart' as auth;
import 'core/provider_nav.dart';
import 'presentation/widgets/nav_bar.dart' as nav;
import 'presentation/screens/splash_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => auth.AuthProvider()),
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
        home: AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 연결 중일 때는 로딩 인디케이터 표시
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 사용자가 로그인한 상태라면 MainScreen으로 이동
        if (snapshot.hasData) {
          return MainScreen();
        }

        // 로그인하지 않은 상태라면 SplashPage로 이동
        return SplashPage();
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
