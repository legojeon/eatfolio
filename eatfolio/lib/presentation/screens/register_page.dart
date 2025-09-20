import 'dart:convert';
import 'dart:io';

import 'package:eatfolio/core/provider_nav.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../widgets/buttons.dart';
import '../../core/fonts.dart';

class RegisterPage extends StatefulWidget {
  final String imagePath;
  final double? latitude;
  final double? longitude;

  const RegisterPage({
    super.key,
    required this.imagePath,
    this.latitude,
    this.longitude,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _rating = 0;
  String? _selectedCategory;
  bool _isSubmitting = false; // 제출 중 상태 추가
  final TextEditingController _memoController = TextEditingController();
  final TextEditingController _foodNameController = TextEditingController();

  final List<String> foodTypes = ['한식', '양식', '일식', '중식'];

  @override
  void dispose() {
    _memoController.dispose();
    _foodNameController.dispose();
    super.dispose();
  }

  /// Uploads the image + metadata to your FastAPI endpoint.
  Future<void> _sendToBackend({
    required String recordId,
    required String userId,
    required String imagePath,
  }) async {
    final uri = Uri.parse('https://eat.coco.io.kr/request_analysis');

    final mimeType = lookupMimeType(imagePath) ?? 'image/jpeg';
    final mediaType = MediaType.parse(mimeType);

    final req = http.MultipartRequest('POST', uri)
      ..fields['record_id'] = recordId
      ..fields['user_id'] = userId
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imagePath,
          contentType: mediaType,
        ),
      );

    final streamed = await req.send().timeout(const Duration(seconds: 25));
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 200) {
      // If your API returns JSON, store it; otherwise this silently skips.
      try {
        final data = jsonDecode(res.body);
        if (data.containsKey('nutrition_info')) {
          await FirebaseFirestore.instance
              .collection('Photos')
              .doc(recordId)
              .update({
                'analyze': true,
                'nutrition_info':
                    data['nutrition_info'], // 중첩된 nutrition_info만 저장
              });
        }
      } catch (_) {
        /* non-JSON or different shape */
      }
    } else {
      // Optional: handle non-200s (log or show a snackbar)
      // print('Upload failed: ${res.statusCode} ${res.body}');
    }
  }

  bool _check_foodname() {
    final foodName = _foodNameController.text.trim();
    if (foodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('음식명을 입력해주세요'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _submitData() async {
    if (_isSubmitting) return; // 이미 제출 중이면 중단

    setState(() {
      _isSubmitting = true; // 제출 시작
    });

    try {
      final recordId = DateTime.now().millisecondsSinceEpoch.toString();
      final userId = FirebaseAuth.instance.currentUser?.uid ?? "guest";

      final now = DateTime.now();
      final hour = now.hour;
      final mealTime = (hour >= 6 && hour < 11)
          ? 'breakfast'
          : (hour >= 11 && hour < 16)
          ? 'lunch'
          : (hour >= 16 && hour < 21)
          ? 'dinner'
          : 'midnight snack';

      // 1) Save basic record first (so you see it immediately in the app)
      await FirebaseFirestore.instance.collection('Photos').doc(recordId).set({
        'record_id': recordId,
        'user_id': userId,
        'rating': _rating,
        'memo': _memoController.text.trim(),
        'food_name': _foodNameController.text.trim().isEmpty
            ? null
            : _foodNameController.text.trim(),
        'image_path': widget.imagePath,
        'created_at': DateTime.now().toIso8601String(),
        'calories': null,
        'food_category': _selectedCategory ?? '기타',
        'analyze': false,
        'location': (widget.latitude != null && widget.longitude != null)
            ? {'latitude': widget.latitude, 'longitude': widget.longitude}
            : null,
        'meal_time': mealTime,
        'nutrition_info': null,
      });

      // 2) Send the file to your FastAPI backend (await, but don’t block UX too long)
      try {
        await _sendToBackend(
          recordId: recordId,
          userId: userId,
          imagePath: widget.imagePath,
        );
      } catch (e) {
        // Swallow upload error so UX still proceeds
        // print('Backend upload error: $e');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Submitted')));

      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        context.read<NavigationProvider>().setSelectedIndex(0);
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving to database: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false; // 제출 완료 (성공/실패 상관없이)
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Back(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Text('Register meal', style: AppFonts.heading3),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.deferToChild, // don't consume TextField taps
        onTap: () {
          final currentFocus = FocusScope.of(context);
          // Only unfocus if the tap wasn't on a TextField
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.unfocus();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 상단: 사진과 입력 필드를 가로로 배치
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 왼쪽: 사진
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(widget.imagePath),
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 오른쪽: 입력 필드들
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 48, // Food Name 입력창 높이를 한 줄 입력에 맞게 줄임
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _foodNameController,
                              style: AppFonts.bodyMedium.copyWith(fontSize: 14),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Food Name',
                                hintStyle: AppFonts.bodyMedium.copyWith(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 85, // Memo 입력창 높이를 늘려서 이미지 하단까지 확장
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _memoController,
                              maxLines: null, // 고정 높이를 사용하므로 maxLines 제거
                              textAlignVertical: TextAlignVertical.top, // 상단 정렬
                              style: AppFonts.bodyMedium.copyWith(fontSize: 14),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Write your thoughts...',
                                hintStyle: AppFonts.bodyMedium.copyWith(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                alignLabelWithHint: true, // 힌트 텍스트도 상단 정렬
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 하단: Rating과 Category
                // Rating 카드
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: const Color(0xFFFF8A65),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text('Rating', style: AppFonts.bodyLarge),
                        ],
                      ),
                      const SizedBox(height: 12),
                      StarRatingButton(
                        rating: _rating,
                        onRatingChanged: (newRating) {
                          setState(() {
                            _rating = newRating;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Category 카드
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_rounded,
                            color: const Color(0xFF26A69A),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text('Category', style: AppFonts.bodyLarge),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          foodTypes.length,
                          (index) => OvalButton(
                            text: foodTypes[index],
                            isSelected: _selectedCategory == foodTypes[index],
                            onPressed: () => setState(() {
                              _selectedCategory =
                                  (_selectedCategory == foodTypes[index])
                                  ? null
                                  : foodTypes[index];
                            }),
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ButtonWide(
                    text: _isSubmitting ? 'Submitting...' : 'Submit',
                    onPressed: _isSubmitting
                        ? null // 제출 중일 때는 비활성화
                        : () {
                            if (_check_foodname()) {
                              _submitData();
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
