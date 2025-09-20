import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';
import './icons.dart';
import './buttons.dart';

class ImageCard extends StatelessWidget {
  final double width;
  final String? imagePath; // 🔹 optional path

  const ImageCard({super.key, required this.width, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width, // square
      decoration: BoxDecoration(
        color: Colors.grey[300], // fallback background
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imagePath != null
            ? _buildImage(context)
            : Icon(Icons.image, size: width / 2, color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    try {
      if (File(imagePath!).existsSync()) {
        return Image.file(
          File(imagePath!),
          fit: BoxFit.cover,
          // 메모리 캐시 활성화
          cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).round(),
          cacheHeight: (width * MediaQuery.of(context).devicePixelRatio)
              .round(),
        );
      }
    } catch (e) {
      // 파일 접근 오류 시
    }

    // 파일이 없거나 접근 실패 시 기본 아이콘
    return Icon(Icons.image, size: width / 2, color: Colors.grey[500]);
  }
}

class BoxCard extends StatelessWidget {
  final double width;
  final double? height; // make nullable
  final Widget? child;

  const BoxCard({
    super.key,
    required this.width,
    this.height, // not required
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height, // null = wrap content
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PillLabel extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final TextStyle? textStyle;

  const PillLabel({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 29.28,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: ShapeDecoration(
        color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(
        text,
        style: (textStyle ?? AppFonts.caption).copyWith(
          color: textColor ?? AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final String food;
  final String time;
  final String category;
  final int stars;
  final String? imagePath;
  final VoidCallback? onPressed;
  const FoodCard({
    super.key,
    required this.food,
    required this.time,
    required this.category,
    required this.stars,
    this.imagePath,
    this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    const double cardHeight = 102;
    const double outerPadding = 1;
    const double innerPadding = 8;
    const double imageWidth = cardHeight - innerPadding * 2;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: outerPadding,
            vertical: outerPadding,
          ),
          child: BoxCard(
            width: double.infinity,
            height: cardHeight,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Padding(
                    padding: EdgeInsets.all(innerPadding),
                    child: ImageCard(width: imageWidth, imagePath: imagePath),
                  ),
                ),
                Positioned(
                  left: 114.34,
                  top: 11.13,
                  child: Text(
                    food,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Positioned(
                  left: 114,
                  top: 39.44,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          PillLabel(text: time),
                          SizedBox(width: 8),
                          PillLabel(text: category),
                        ],
                      ),
                      SizedBox(height: 10),
                      Stars(count: stars, size: 16),
                    ],
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(child: Forward(onPressed: onPressed)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DayCard extends StatelessWidget {
  final int day;
  final List<Map<String, String?>> imageData; // imagePath와 recordId를 포함하는 맵 리스트
  final VoidCallback? onPressed;

  const DayCard({
    super.key,
    required this.day,
    required this.imageData,
    this.onPressed,
  });

  // 요일을 계산하는 헬퍼 메서드
  String _getDayOfWeek(int day) {
    // 현재 월의 해당 날짜로 DateTime 생성
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, day);

    // 요일을 영어 약자로 반환
    switch (date.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 102;
    const double outerPadding = 1;
    const double innerPadding = 8;
    const double imageWidth = cardHeight - innerPadding * 2; // FoodCard와 동일한 크기

    return GestureDetector(
      onTap: onPressed, // 터치 이벤트 처리
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: outerPadding,
              vertical: outerPadding,
            ),
            child: BoxCard(
              width: double.infinity,
              height: cardHeight,
              child: Padding(
                padding: EdgeInsets.all(innerPadding),
                child: Row(
                  children: [
                    // 왼쪽 날짜 표시 (정사각형, 배경색 없음)
                    Container(
                      width: imageWidth, // FoodCard의 ImageCard와 동일한 크기
                      height: imageWidth, // 정사각형
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDayOfWeek(day), // 요일 계산 함수 호출
                            style: AppFonts.caption.copyWith(
                              color: AppColors.primary.withValues(alpha: 0.7),
                              fontSize: 14, // 글씨 크기 증가
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$day',
                            style: AppFonts.heading2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // 오른쪽 이미지들 (최대 3개) - 가운데 정렬
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imageData.length.clamp(0, 3), // 최대 3개로 제한
                            (index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index < 2 ? 8.0 : 0,
                                ), // 마지막 이미지 제외하고 오른쪽 여백
                                child: ImageCard(
                                  width:
                                      (MediaQuery.of(context).size.width -
                                          24 * 2 -
                                          8 * 2 -
                                          imageWidth -
                                          16 -
                                          16) /
                                      3, // 남은 공간을 3등분
                                  imagePath: imageData[index]['imagePath'],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
