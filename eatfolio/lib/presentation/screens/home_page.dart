import 'package:flutter/material.dart';
import '../../core/fonts.dart';
import '../widgets/searchbar.dart' as custom;
import '../widgets/cards.dart';
import '../widgets/buttons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: null,
        centerTitle: true,
        title: Text('eatfolio', style: AppFonts.logotext),
      ),
      body: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          // 키보드 숨기기
          print('키보드 숨기기');
          FocusScope.of(context).unfocus();
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                custom.SearchBar(
                  onFilterPressed: () {
                    print('필터 버튼 클릭');
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const FilterDialog();
                      },
                    );
                  },
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
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  int starRating = 0;

  // 음식종류 상태 관리
  List<bool> foodTypeSelections = [false, false, false, false];
  List<String> foodTypes = ['한식', '양식', '일식', '중식'];

  // 시간대 상태 관리
  List<bool> timeSelections = [false, false, false];
  List<String> timeTypes = ['아침', '점심', '저녁'];

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
              // 상단 영역
              Column(
                children: [
                  Text('Filter your search', style: AppFonts.bodyLarge),
                  SizedBox(height: 20),
                  Text('Star Rating', style: AppFonts.bodySmall),
                  SizedBox(height: 8),
                  StarRatingButton(
                    rating: starRating,
                    size: 30,
                    onRatingChanged: (rating) {
                      setState(() {
                        starRating = rating;
                      });
                      print('Star rating changed to: $rating');
                    },
                  ),
                  SizedBox(height: 30),
                  Text('음식종류', style: AppFonts.bodySmall),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(
                      foodTypes.length,
                      (index) => OvalButton(
                        text: foodTypes[index],
                        isSelected: foodTypeSelections[index],
                        onPressed: () {
                          setState(() {
                            foodTypeSelections[index] =
                                !foodTypeSelections[index];
                          });
                          print(
                            '음식종류 선택: ${foodTypes[index]} - ${foodTypeSelections[index]}',
                          );
                        },
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text('시간대', style: AppFonts.bodySmall),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(
                      timeTypes.length,
                      (index) => OvalButton(
                        text: timeTypes[index],
                        isSelected: timeSelections[index],
                        onPressed: () {
                          setState(() {
                            timeSelections[index] = !timeSelections[index];
                          });
                          print(
                            '시간대 선택: ${timeTypes[index]} - ${timeSelections[index]}',
                          );
                        },
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
              // 하단 버튼
              ButtonWide(
                text: 'Filter',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
