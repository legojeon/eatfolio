import 'package:eatfolio/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/provider_nav.dart';
import '../../core/fonts.dart';
import 'buttons.dart'; // buttons.dart import 추가

class Tab extends StatelessWidget {
  const Tab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return SizedBox(
          height: 95,
          child: Stack(
            children: [
              // 메인 네비게이션 바
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.navBackground,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(context, Icons.home, 'Home', navigationProvider.selectedIndex == 0, 0),
                      _buildNavItem(context, Icons.calendar_today, 'Calendar', navigationProvider.selectedIndex == 1, 1),
                      SizedBox(width: 50),
                      _buildNavItem(context, Icons.assessment, 'Report', navigationProvider.selectedIndex == 3, 3),
                      _buildNavItem(context, Icons.person, 'Profile', navigationProvider.selectedIndex == 4, 4),
                    ],
                  ),
                ),
              ),
              // 중앙 플로팅 버튼 - buttons.dart의 FloatingNavButton 사용
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: CameraButton(
                    onPressed: () => navigationProvider.setSelectedIndex(2),
                    icon: Icons.camera_alt,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => context.read<NavigationProvider>().setSelectedIndex(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.navSelected : AppColors.navUnselected,
            size: 24,
          ),
          if (label.isNotEmpty) SizedBox(height: 4),
          if (label.isNotEmpty)
            Text(
              label,
              style: isSelected ? AppFonts.navSelected : AppFonts.navUnselected,
            ),
        ],
      ),
    );
  }
}