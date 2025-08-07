import 'package:flutter/material.dart';
import '../presentation/screens/home_page.dart'; // MapPage → HomePage
import '../presentation/screens/calendar_page.dart';
import '../presentation/screens/profile_page.dart';
import '../presentation/screens/report_page.dart';
import '../presentation/screens/camera_page.dart'; // CameraPage 추가

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Widget getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const HomePage(); // MapPage → HomePage
      case 1:
        return const CalendarPage();
      case 2:
        return const CameraPage(); // HomePage → CameraPage
      case 3:
        return const ReportPage();
      case 4:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }

  String getCurrentPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Home Page'; // Map Page → Home Page
      case 1:
        return 'Calendar Page';
      case 2:
        return 'Camera Page'; // Home Page → Camera Page
      case 3:
        return 'Report Page';
      case 4:
        return 'Profile Page';
      default:
        return 'Home Page';
    }
  }

  bool shouldShowNavigationBar() {
    switch (_selectedIndex) {
      case 2: // Camera 페이지에서는 네비게이션 바 숨김
        return false;
      default:
        return true;
    }
  }
}
