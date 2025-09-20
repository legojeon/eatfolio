import 'package:eatfolio/presentation/screens/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/cards.dart';
import '../../core/fonts.dart';
import '../../core/provider_auth.dart' as auth;
import '../../data/repositories/photo_repository.dart';
import '../../core/utils/date_utils.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late int currentYear;
  late int currentMonth;
  Set<int> selectedDays = {}; // 선택된 날짜들 (여러 개 동시 선택 가능)

  // 데이터 캐싱을 위한 변수들
  List<Map<String, String?>>? _cachedPhotos;
  Map<int, List<Map<String, String?>>>? _cachedPhotosByDay;
  List<int>? _cachedSortedDays;

  // 선택된 날짜의 상세 데이터 (FoodCard용)
  Map<String, dynamic>? _selectedDayDetails;

  // 데이터 로딩 상태
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 현재 시간으로 초기화
    final DateTime now = DateTime.now();
    currentYear = now.year;
    currentMonth = now.month;
    _loadMonthData();
  }

  /// 월 데이터 로드
  Future<void> _loadMonthData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String userId =
          context.read<auth.AuthProvider>().currentUser?.uid ?? 'guest';
      final photos = await PhotoRepository.getPhotosByMonthOnce(
        userId,
        currentYear,
        currentMonth,
      );

      if (mounted) {
        setState(() {
          _cachedPhotos = photos;
          _cachedPhotosByDay = PhotoDateUtils.groupPhotosByDay(photos);
          _cachedSortedDays = PhotoDateUtils.getSortedDays(_cachedPhotosByDay!);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ 월 데이터 로드 실패: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 월 이름을 영어로 반환
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Unknown';
    }
  }

  /// 이전 달로 이동
  void _goToPreviousMonth() {
    setState(() {
      if (currentMonth == 1) {
        currentMonth = 12;
        currentYear--;
      } else {
        currentMonth--;
      }
      // 월 변경 시 캐시 초기화
      _clearCache();
    });
  }

  /// 다음 달로 이동
  void _goToNextMonth() {
    setState(() {
      if (currentMonth == 12) {
        currentMonth = 1;
        currentYear++;
      } else {
        currentMonth++;
      }
      // 월 변경 시 캐시 초기화
      _clearCache();
    });
  }

  /// 캐시 초기화
  void _clearCache() {
    _cachedPhotos = null;
    _cachedPhotosByDay = null;
    _cachedSortedDays = null;
    selectedDays.clear(); // 선택된 날짜들 초기화
    _selectedDayDetails = null; // 상세 데이터도 초기화
    _loadMonthData(); // 새로운 월 데이터 로드
  }

  /// 선택된 날짜의 상세 데이터 로드
  Future<void> _loadDayDetails(
    int day,
    List<Map<String, String?>> dayPhotos,
  ) async {
    try {
      // 해당 날짜의 각 음식에 대한 요약 정보를 Firestore에서 가져오기
      final details = <String, dynamic>{};

      for (final photo in dayPhotos) {
        final recordId = photo['recordId'];
        if (recordId != null) {
          // PhotoRepository를 통해 FoodCard용 요약 데이터 가져오기
          final summary = await PhotoRepository.getFoodSummary(recordId);
          if (summary != null) {
            details[recordId] = summary;
          }
        }
      }

      // UI 업데이트 - 기존 데이터를 유지하면서 새로운 데이터 추가
      if (mounted) {
        setState(() {
          if (_selectedDayDetails == null) {
            _selectedDayDetails = details;
          } else {
            // 기존 데이터를 유지하면서 새로운 데이터 추가
            _selectedDayDetails!.addAll(details);
          }
        });
      }
    } catch (e) {
      print('❌ Day $day 상세 데이터 로드 실패: $e');
      // 에러 발생 시에도 기본 데이터로 표시
      setState(() {
        _selectedDayDetails = {};
      });
    }
  }

  /// 캘린더 콘텐츠 빌드
  Widget _buildCalendarContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cachedPhotos == null || _cachedPhotos!.isEmpty) {
      return const Center(child: Text('이번 달에 저장된 사진이 없습니다.'));
    }

    final photos = _cachedPhotos!;
    final photosByDay = _cachedPhotosByDay!;
    final sortedDays = _cachedSortedDays!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        children: [
          ...sortedDays.map((day) {
            final dayPhotos = photosByDay[day]!;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: DayCard(
                    key: ValueKey(day),
                    day: day,
                    imageData: dayPhotos,
                    onPressed: () {
                      print('🔍 DayCard onPressed 호출됨! Day: $day');

                      // 해당 날짜의 모든 recordId 출력
                      print('📅 Day $day의 음식 recordId들:');
                      for (int i = 0; i < dayPhotos.length; i++) {
                        final recordId = dayPhotos[i]['recordId'];
                        final imagePath = dayPhotos[i]['imagePath'];
                        print('  ${i + 1}. recordId: $recordId');
                        print('     imagePath: $imagePath');
                      }
                      print('📅 총 ${dayPhotos.length}개의 음식');

                      // 선택된 날짜 토글 (이미 선택된 날짜면 닫기)
                      if (selectedDays.contains(day)) {
                        // 같은 날짜 터치 시 닫기
                        selectedDays.remove(day);
                        // 해당 날짜의 상세 데이터 제거
                        if (_selectedDayDetails != null) {
                          final keysToRemove = _selectedDayDetails!.keys
                              .where(
                                (key) => dayPhotos.any(
                                  (photo) => photo['recordId'] == key,
                                ),
                              )
                              .toList();
                          for (final key in keysToRemove) {
                            _selectedDayDetails!.remove(key);
                          }
                        }
                        setState(() {});
                      } else {
                        // 새로운 날짜 선택 시 상세 데이터 로드
                        selectedDays.add(day);
                        _loadDayDetails(day, dayPhotos);
                      }

                      // SnackBar로도 확인 가능
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            selectedDays.contains(day)
                                ? 'Day $day 열림'
                                : 'Day $day 닫힘',
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
                // 선택된 날짜일 때 FoodCard들 표시 (애니메이션 포함)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: selectedDays.contains(day)
                      ? Column(
                          children: dayPhotos
                              .map(
                                (photo) => Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: FoodCard(
                                      food:
                                          _getFoodName(photo['recordId']) ??
                                          'null',
                                      time:
                                          _getMealTime(photo['recordId']) ??
                                          'null',
                                      category:
                                          _getFoodCategory(photo['recordId']) ??
                                          'null',
                                      stars: _getRating(photo['recordId']) ?? 0,
                                      imagePath: photo['imagePath'],
                                      onPressed: () {
                                        final recordId = photo['recordId'];
                                        if (recordId != null &&
                                            recordId.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DetailPage(
                                                recordId: recordId,
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '잘못된 항목입니다 (recordId 없음)',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            );
          }).toList(),
          // 네비게이션바 높이만큼 하단 여백 추가
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  /// 음식 이름 가져오기 (요약 데이터)
  String? _getFoodName(String? recordId) {
    if (recordId != null && _selectedDayDetails != null) {
      final summary = _selectedDayDetails![recordId];
      if (summary != null && summary['food_name'] != null) {
        return summary['food_name'];
      }
    }
    return null;
  }

  /// 식사 시간 가져오기 (요약 데이터)
  String? _getMealTime(String? recordId) {
    if (recordId != null && _selectedDayDetails != null) {
      final summary = _selectedDayDetails![recordId];
      if (summary != null && summary['meal_time'] != null) {
        return summary['meal_time'];
      }
    }
    return null;
  }

  /// 음식 카테고리 가져오기 (요약 데이터)
  String? _getFoodCategory(String? recordId) {
    if (recordId != null && _selectedDayDetails != null) {
      final summary = _selectedDayDetails![recordId];
      if (summary != null && summary['food_category'] != null) {
        return summary['food_category'];
      }
    }
    return null;
  }

  /// 평점 가져오기 (요약 데이터)
  int? _getRating(String? recordId) {
    if (recordId != null && _selectedDayDetails != null) {
      final summary = _selectedDayDetails![recordId];
      if (summary != null && summary['rating'] != null) {
        return summary['rating'];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String userId =
        context.watch<auth.AuthProvider>().currentUser?.uid ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_getMonthName(currentMonth)} $currentYear',
          style: AppFonts.heading3,
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // DayCard와 동일한 흰색
        foregroundColor: Colors.black, // 텍스트 및 아이콘 색상
        surfaceTintColor: Colors.transparent, // Material 3 회색 효과 제거
        elevation: 2, // 그림자 효과
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _goToPreviousMonth,
          tooltip: '이전 달',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _goToNextMonth,
            tooltip: '다음 달',
          ),
        ],
      ),
      extendBody: true, // 스크롤 영역 확장
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          // 왼쪽으로 스와이프 → 다음 달
          if (details.primaryVelocity! > 0) {
            _goToNextMonth();
          }
          // 오른쪽으로 스와이프 → 이전 달
          else if (details.primaryVelocity! < 0) {
            _goToPreviousMonth();
          }
        },
        child: _buildCalendarContent(),
      ),
    );
  }
}
