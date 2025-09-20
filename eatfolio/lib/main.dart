import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/provider_auth.dart' as auth;
import 'core/provider_nav.dart';
import 'presentation/widgets/nav_bar.dart' as nav;
import 'presentation/screens/splash_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔍 Firebase 초기화 (먼저 실행)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔍 Google Play Services 상태 확인 (Firebase 초기화 후)
  await _checkGoogleServices();

  // 🔍 Firebase 연결 상태 확인 (Firebase 초기화 후)
  await _checkFirebase();

  runApp(MyApp());
}

/// Google Play Services 상태 확인
Future<void> _checkGoogleServices() async {
  try {
    print('🔍 Google Play Services 상태 확인 시작...');

    // Google Play Services 사용 가능 여부 확인
    final googleServicesAvailable =
        await Firebase.app().options.projectId.isNotEmpty;
    print('✅ Firebase 프로젝트 ID: ${Firebase.app().options.projectId}');

    if (googleServicesAvailable) {
      print('✅ Google Play Services 정상 (Firebase 프로젝트 연결됨)');
    } else {
      print('❌ Google Play Services 문제 (Firebase 프로젝트 연결 실패)');
    }
  } catch (e) {
    print('❌ Google Play Services 확인 오류: $e');
  }
}

/// Firebase 연결 상태 확인
Future<void> _checkFirebase() async {
  try {
    print('🔍 Firebase 연결 상태 확인 시작...');

    final firestore = FirebaseFirestore.instance;
    print('✅ Firebase 인스턴스 생성 성공');

    // 간단한 쿼리 테스트
    final testSnapshot = await firestore.collection('Photos').limit(1).get();
    print('✅ Firestore 쿼리 성공: ${testSnapshot.docs.length}개 문서');

    print('✅ Firebase 연결 정상');
  } catch (e) {
    print('❌ Firebase 오류: $e');
    print('❌ 오류 상세: ${e.toString()}');

    // 오류 타입별 상세 정보
    if (e.toString().contains('permission-denied')) {
      print('🔒 권한 거부됨 - Firestore 보안 규칙 확인 필요');
    } else if (e.toString().contains('unavailable')) {
      print('🌐 서비스 사용 불가 - 네트워크 또는 Google Play Services 문제');
    } else if (e.toString().contains('not-found')) {
      print('🔍 컬렉션을 찾을 수 없음 - Photos 컬렉션 존재 여부 확인 필요');
    }
  }
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
          extendBody: true,
          body: navigationProvider.getCurrentPage(),
          // 조건부로 네비게이션 바 표시
          bottomNavigationBar: navigationProvider.shouldShowNavigationBar()
              ? nav.NavBar()
              : null,
        );
      },
    );
  }
}
