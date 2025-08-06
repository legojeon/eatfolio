import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';

class ButtonWide extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  
  const ButtonWide({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
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
  
  const OvalButton({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 텍스트 크기를 측정하여 적절한 패딩 계산
    final textStyle = isSelected ? AppFonts.buttonPrimary.copyWith(color: AppColors.white) : AppFonts.buttonSmall;
    
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // 텍스트 길이에 따라 동적 너비 계산 (최소 너비 94, 좌우 패딩 34)
    final textWidth = textPainter.width;
    final buttonWidth = (textWidth + 42).clamp(60.0, double.infinity);
    
    return GestureDetector(
      onTap: onPressed,
              child: Container(
          width: buttonWidth,
          height: 42,
          decoration: ShapeDecoration(
            color: isSelected ? AppColors.buttonPrimary : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(33),
                          side: isSelected ? BorderSide.none : BorderSide(
              color: AppColors.borderLight,
              width: 2,
            ),
            ),
          ),
        child: Center(
          child: Text(
            text,
            style: textStyle,
          ),
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
      child: Container(
        width: 42,
        height: 42,
        decoration: ShapeDecoration(
          color: isSelected ? AppColors.buttonPrimary : Colors.white,
          shape: OvalBorder(
            side: isSelected ? BorderSide.none : BorderSide(
              width: 2,
              color: AppColors.borderLight,
            ),
          ),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: isSelected ? AppFonts.buttonPrimary.copyWith(color: AppColors.white) : AppFonts.buttonSmall,
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
    return GestureDetector( // GestureDetector로 감싸기
      onTap: onPressed, // 탭 이벤트 연결
      child: Column(
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
                    color: AppColors.grey,
                    shape: OvalBorder(),
                  ),
                ),
                // 뒤로가기 아이콘을 중앙에 배치
                Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.white,
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

class XButton extends StatelessWidget {
  final VoidCallback? onPressed; // onPressed 콜백 추가
  
  const XButton({
    super.key,
    this.onPressed, // onPressed parameter 추가
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // GestureDetector로 감싸기
      onTap: onPressed, // 탭 이벤트 연결
      child: Column(
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
                    color: AppColors.grey,
                    shape: OvalBorder(),
                  ),
                ),
                // X 아이콘을 중앙에 배치
                Center(
                  child: Icon(
                    Icons.close,
                    color: AppColors.white,
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

// 네비게이션 바 중앙 플로팅 버튼
class CameraButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  
  const CameraButton({
    super.key,
    this.onPressed,
    this.icon = Icons.camera_alt,
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

class FilterButton1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 94,
          height: 46,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(33),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 17,
                top: 14,
                child: Text(
                  'Delivery',
                  style: AppFonts.buttonSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StarRatingButton extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChanged;
  
  const StarRatingButton({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 4 ? 8.0 : 0.0), // 마지막 별 제외하고 오른쪽 패딩 추가
          child: GestureDetector(
            onTap: () => onRatingChanged(index + 1),
            child: Container(
              width: 42,
              height: 42,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: OvalBorder(
                  side: BorderSide(
                    width: 2,
                    color: AppColors.borderLight,
                  ),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.star,
                  color: index < rating ? AppColors.iconSelected : AppColors.iconUnselected,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}