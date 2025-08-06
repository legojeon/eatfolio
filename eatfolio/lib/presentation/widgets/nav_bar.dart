import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/provider_nav.dart';
import '../../core/constants.dart';

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
              // 중앙 플로팅 버튼
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => navigationProvider.setSelectedIndex(2),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.buttonPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowMedium,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: AppColors.buttonText,
                        size: 30,
                      ),
                    ),
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
              style: TextStyle(
                color: isSelected ? AppColors.textSelected : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}