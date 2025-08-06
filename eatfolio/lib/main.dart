import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/provider_nav.dart';
import 'presentation/widgets/nav_bar.dart' as nav;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NavigationProvider(),
      child: MaterialApp(
        title: 'Eatfolio',
        home: MainScreen(),
      ),
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
          appBar: AppBar(
            title: Text(navigationProvider.getCurrentPageTitle()),
          ),
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