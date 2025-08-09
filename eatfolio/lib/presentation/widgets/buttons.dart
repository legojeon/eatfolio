import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';

class ButtonWide extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const ButtonWide({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          SizedBox(
            width: 327,
            height: 62,
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
                    style: AppFonts.buttonPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OvalButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onPressed;
  final double? size;

  const OvalButton({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onPressed,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    // 기본 사이즈 설정
    final defaultSize = 42.0;
    final buttonSize = size ?? defaultSize;

    // 텍스트 스타일 통일 (buttonSmall 사용)
    final textStyle = isSelected
        ? AppFonts.buttonSmall.copyWith(color: AppColors.white)
        : AppFonts.buttonSmall;

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // 텍스트 길이에 따라 동적 너비 계산
    final textWidth = textPainter.width;
    final buttonWidth = (textWidth + 32).clamp(40.0, double.infinity);

    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: buttonWidth,
        height: buttonSize,
        child: Container(
          decoration: ShapeDecoration(
            color: isSelected ? AppColors.buttonPrimary : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonSize / 2),
              side: isSelected
                  ? BorderSide.none
                  : BorderSide(color: AppColors.borderLight, width: 2),
            ),
          ),
          child: Center(child: Text(text, style: textStyle)),
        ),
      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onPressed;

  const CircleButton({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 42,
        height: 42,
        child: Container(
          decoration: ShapeDecoration(
            color: isSelected ? AppColors.buttonPrimary : Colors.white,
            shape: OvalBorder(
              side: isSelected
                  ? BorderSide.none
                  : BorderSide(width: 2, color: AppColors.borderLight),
            ),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: isSelected
                  ? AppFonts.buttonPrimary.copyWith(color: AppColors.white)
                  : AppFonts.buttonSmall,
            ),
          ),
        ),
      ),
    );
  }
}

class Back extends StatelessWidget {
  final VoidCallback? onPressed; // onPressed 콜백 추가

  const Back({
    super.key,
    this.onPressed, // onPressed parameter 추가
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // GestureDetector로 감싸기
      onTap: onPressed, // 탭 이벤트 연결
      child: Column(
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: Stack(
              children: [
                // 배경 원형 버튼
                Container(
                  width: 45,
                  height: 45,
                  decoration: ShapeDecoration(
                    color: AppColors.greyLight,
                    shape: OvalBorder(),
                  ),
                ),
                // 뒤로가기 아이콘을 중앙에 배치
                Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Forward extends StatelessWidget {
  final VoidCallback? onPressed;

  const Forward({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 45,
        height: 45,
        child: Center(
          child: Icon(
            Icons.arrow_forward,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SettingsButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 45,
        height: 45,
        child: Center(
          child: Icon(Icons.settings, color: AppColors.textPrimary, size: 24),
        ),
      ),
    );
  }
}

class XButton extends StatelessWidget {
  final VoidCallback? onPressed; // onPressed 콜백 추가

  const XButton({
    super.key,
    this.onPressed, // onPressed parameter 추가
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // GestureDetector로 감싸기
      onTap: onPressed, // 탭 이벤트 연결
      child: Column(
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: Stack(
              children: [
                // 배경 원형 버튼
                Container(
                  width: 45,
                  height: 45,
                  decoration: ShapeDecoration(
                    color: AppColors.grey,
                    shape: OvalBorder(),
                  ),
                ),
                // X 아이콘을 중앙에 배치
                Center(
                  child: Icon(Icons.close, color: AppColors.white, size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 네비게이션 바 중앙 플로팅 버튼
class CameraButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;

  const CameraButton({super.key, this.onPressed, this.icon = Icons.camera_alt});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Container(
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
          child: Icon(icon, color: AppColors.buttonText, size: 30),
        ),
      ),
    );
  }
}

class StarRatingButton extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChanged;
  final double size;

  const StarRatingButton({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 42.0, // 기본 크기
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.only(
            right: index < 4 ? 8.0 : 0.0,
          ), // 마지막 별 제외하고 오른쪽 패딩 추가
          child: GestureDetector(
            onTap: () => onRatingChanged(index + 1),
            child: SizedBox(
              width: size,
              height: size,
              child: Container(
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: OvalBorder(
                    side: BorderSide(width: 2, color: AppColors.borderLight),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.star,
                    color: index < rating
                        ? AppColors.iconSelected
                        : AppColors.iconUnselected,
                    size: size * 0.48, // 별 아이콘 크기를 버튼 크기에 비례하게 설정
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class Logout extends StatelessWidget {
  final VoidCallback? onPressed;

  const Logout({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(Icons.logout, color: AppColors.textPrimary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Log Out',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
