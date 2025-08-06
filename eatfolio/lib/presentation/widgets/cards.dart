import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final double width;
  
  const ImageCard({
    super.key,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width, // 정사각형을 위해 width와 동일한 height 설정
      decoration: BoxDecoration(
        color: Colors.grey[300], // 회색 배경
        borderRadius: BorderRadius.circular(8), // 모서리 둥글게
      ),
      child: Stack(
        children: [
          Positioned(
            right: 16,
            bottom: 16,
            child: Opacity(
              opacity: 0.20,
              child: Container(
                width: 37,
                height: 37,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: OvalBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BoxCard extends StatelessWidget {
  final double width;
  final double height;
  
  const BoxCard({
    super.key,
    required this.width,
    required this.height,
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
    );
  }
}