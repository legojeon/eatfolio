import 'package:flutter/material.dart';
import '../../core/constants.dart';

class ButtonWide extends StatelessWidget {
  final String text;
  
  const ButtonWide({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 327,
          height: 62,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Stack(
            children: [
              // 배경 버튼
              Container(
                width: 327,
                height: 62,
                decoration: ShapeDecoration(
                  color: AppColors.buttonPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // 텍스트를 중앙에 배치
              Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.buttonText,
                    fontSize: 16,
                    fontFamily: 'Sen',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class Back extends StatelessWidget {
  const Back({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 45,
          height: 45,
          child: Stack(
            children: [
              // 배경 원형 버튼
              Container(
                width: 45,
                height: 45,
                decoration: ShapeDecoration(
                  color: AppColors.grey, // constants.dart에서 정의한 회색 사용
                  shape: OvalBorder(),
                ),
              ),
              // 뒤로가기 아이콘을 중앙에 배치
              Center(
                child: Icon(
                  Icons.arrow_back, // 뒤로가기 아이콘
                  color: AppColors.white, // 흰색 아이콘
                  size: 24, // 아이콘 크기
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


// 네비게이션 바 중앙 플로팅 버튼
class CameraButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  
  const CameraButton({
    super.key,
    this.onPressed,
    this.icon = Icons.camera_alt, // 기본값은 카메라 아이콘
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
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
          icon,
          color: AppColors.buttonText,
          size: 30,
        ),
      ),
    );
  }
}