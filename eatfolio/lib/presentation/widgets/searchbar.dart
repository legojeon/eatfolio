import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/fonts.dart';

class SearchBar extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onFilterPressed;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  const SearchBar({
    super.key,
    this.hintText = 'Search...',
    this.controller,
    this.onFilterPressed,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  @override
  void dispose() {
    // Only dispose if we created it
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _triggerSearch() {
    final text = _controller.text.trim();
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    // Reuse existing onSubmitted callback so HomePage logic stays the same
    widget.onSubmitted?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 327,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          // 왼쪽 돋보기 아이콘 (탭하면 검색 실행)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: _triggerSearch,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.search, color: AppColors.grey, size: 24),
              ),
            ),
          ),

          // 검색 입력 필드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _controller,
                onChanged: widget.onChanged,
                onSubmitted: (v) {
                  // Enter/IME search
                  widget.onSubmitted?.call(v.trim());
                },
                textInputAction: TextInputAction.search,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
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
              onTap: widget.onFilterPressed,
              child: const Icon(
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
