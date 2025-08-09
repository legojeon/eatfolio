import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';
import './icons.dart';
import './buttons.dart';

class ImageCard extends StatelessWidget {
  final double width;

  const ImageCard({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width, // 정사각형을 위해 width와 동일한 height 설정
      decoration: BoxDecoration(
        color: Colors.grey[300], // 회색 배경
        borderRadius: BorderRadius.circular(8), // 모서리 둥글게
      ),
      child: Stack(children: [

        ],
      ),
    );
  }
}

class BoxCard extends StatelessWidget {
  final double width;
  final double height;
  final Widget? child;

  const BoxCard({
    super.key,
    required this.width,
    required this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white, // 흰색 배경
        borderRadius: BorderRadius.circular(8), // 모서리 둥글게
        boxShadow: [
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
  final VoidCallback? onPressed;
  const FoodCard({
    super.key,
    required this.food,
    required this.time,
    required this.category,
    required this.stars,
    this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    const double cardHeight = 102;
    const double outerPadding = 8;
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
                    child: ImageCard(width: imageWidth),
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
