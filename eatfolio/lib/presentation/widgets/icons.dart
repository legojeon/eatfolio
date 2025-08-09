import 'package:flutter/material.dart';
import '../../core/constants.dart';

class SmallStar extends StatelessWidget {
  final double size;
  final Color color;

  const SmallStar({super.key, this.size = 14, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.star, size: size, color: color);
  }
}

class Stars extends StatelessWidget {
  final int count;
  final double size;
  final Color color;
  final double spacing;

  const Stars({
    super.key,
    required this.count,
    this.size = 14,
    this.color = AppColors.primary,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => Padding(
          padding: EdgeInsets.only(right: index == count - 1 ? 0 : spacing),
          child: SmallStar(size: size, color: color),
        ),
      ),
    );
  }
}
