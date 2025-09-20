import 'package:eatfolio/core/fonts.dart';
import 'package:eatfolio/presentation/widgets/buttons.dart';
import 'package:eatfolio/presentation/widgets/cards.dart';
import 'package:eatfolio/presentation/widgets/searchbar.dart' as custom;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'search_page.dart';
import 'detail_page.dart';
import 'package:eatfolio/core/utils/filter_options.dart';
import '../../core/provider_auth.dart' as auth;
import '../../data/repositories/photo_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FilterOptions? _savedFilters; // ✅ single source

  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 포커스 해제하여 키보드가 올라오지 않도록 함
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  Future<void> _openFilterDialog() async {
    final result = await showDialog<FilterOptions>(
      context: context,
      builder: (_) => FilterDialog(initial: _savedFilters),
    );
    if (result != null) {
      setState(() => _savedFilters = result);
    }
  }

  void _goSearch(String value) {
    final query = value.trim(); // allow empty -> show all
    FocusScope.of(context).unfocus();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchPage(
          initialQuery: query,
          filters: _savedFilters,
          userId: userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - (24 * 2) - (8 * 2)) / 3;
    final String userId =
        context.watch<auth.AuthProvider>().currentUser?.uid ?? 'guest';

    return GestureDetector(
      onTap: () {
        print("배경 터치 감지됨!"); // 디버깅용
        // 키보드 내리기
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: null,
          centerTitle: true,
          title: Text('eatfolio', style: AppFonts.logotext),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                custom.SearchBar(
                  onSubmitted: _goSearch, // Enter key
                  // If your SearchBar calls onSubmitted when 🔍 is pressed,
                  // you don't need a separate handler here.
                  onFilterPressed: _openFilterDialog,
                ),
                const SizedBox(height: 24),

                // 피드 이미지 그리드
                Expanded(
                  child: StreamBuilder<List<DocumentSnapshot>>(
                    stream: PhotoRepository.getUserPhotos(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('아직 저장된 사진이 없습니다.'));
                      }

                      final photos = snapshot.data!;

                      return GridView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 80.0, // 네비게이션 바 높이 + 여유 공간
                        ),
                        itemCount: photos.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                        itemBuilder: (context, index) {
                          final photo = photos[index];
                          final imagePath = photo['image_path'] as String?;
                          final recordId = photo.id; // 🔹 Firestore 문서 ID

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailPage(recordId: recordId),
                                ),
                              );
                            },
                            child: ImageCard(
                              width: cardWidth,
                              imagePath: imagePath,
                            ),
                          );
                        },
                      );
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

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key, this.initial});
  final FilterOptions? initial;

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final List<String> foodTypes = ['한식', '양식', '일식', '중식'];
  final List<String> timeTypes = ['아침', '점심', '저녁'];

  late int starRating;
  late List<bool> foodTypeSelections;
  late List<bool> timeSelections;

  @override
  void initState() {
    super.initState();
    starRating = widget.initial?.minStars ?? 0;

    final initialCats = widget.initial?.categories ?? const <String>[];
    foodTypeSelections = List.generate(
      foodTypes.length,
      (i) => initialCats.contains(foodTypes[i]),
    );

    // map KO -> EN for initial selections
    final initialTimesEn = widget.initial?.mealTimes ?? const <String>[];
    const localKoToEn = {'아침': 'breakfast', '점심': 'lunch', '저녁': 'dinner'};
    timeSelections = List.generate(
      timeTypes.length,
      (i) => initialTimesEn.contains(localKoToEn[timeTypes[i]]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: BoxCard(
        width: 300,
        height: 420,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text('Filter your search', style: AppFonts.bodyLarge),
                  const SizedBox(height: 20),
                  Text('Star Rating', style: AppFonts.bodySmall),
                  const SizedBox(height: 8),
                  StarRatingButton(
                    rating: starRating,
                    size: 30,
                    onRatingChanged: (rating) {
                      setState(() {
                        // Tap the same rating again -> unset (0)
                        starRating = (starRating == rating) ? 0 : rating;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  Text('음식종류', style: AppFonts.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(
                      foodTypes.length,
                      (index) => OvalButton(
                        text: foodTypes[index],
                        isSelected: foodTypeSelections[index],
                        onPressed: () => setState(() {
                          foodTypeSelections[index] =
                              !foodTypeSelections[index];
                        }),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text('시간대', style: AppFonts.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(
                      timeTypes.length,
                      (index) => OvalButton(
                        text: timeTypes[index],
                        isSelected: timeSelections[index],
                        onPressed: () => setState(() {
                          timeSelections[index] = !timeSelections[index];
                        }),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
              ButtonWide(
                text: 'Save filters',
                onPressed: () {
                  final selectedCategories = <String>[
                    for (int i = 0; i < foodTypes.length; i++)
                      if (foodTypeSelections[i]) foodTypes[i],
                  ];

                  const localKoToEn = {
                    '아침': 'breakfast',
                    '점심': 'lunch',
                    '저녁': 'dinner',
                  };
                  final selectedTimesEn = <String>[
                    for (int i = 0; i < timeTypes.length; i++)
                      if (timeSelections[i]) localKoToEn[timeTypes[i]]!,
                  ];

                  final filters = FilterOptions(
                    minStars: starRating > 0 ? starRating : null,
                    categories: selectedCategories.isNotEmpty
                        ? selectedCategories
                        : null,
                    mealTimes: selectedTimesEn.isNotEmpty
                        ? selectedTimesEn
                        : null,
                  );

                  Navigator.pop(context, filters);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
