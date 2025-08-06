import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';

class SearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onFilterPressed;
  final Function(String)? onChanged;
  
  const SearchBar({
    super.key,
    this.hintText = 'Search...',
    this.controller,
    this.onFilterPressed,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 327,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 왼쪽 돋보기 아이콘
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Icon(
              Icons.search,
              color: AppColors.grey,
              size: 24,
            ),
          ),
          
          // 검색 입력 필드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          
          // 오른쪽 필터 아이콘
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: onFilterPressed,
              child: Icon(
                Icons.filter_list,
                color: AppColors.grey,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}