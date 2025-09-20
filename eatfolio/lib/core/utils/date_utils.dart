/// 사진 날짜 관련 유틸리티 함수들을 모아놓은 클래스
class PhotoDateUtils {
  /// 사진 데이터를 날짜별로 그룹화하는 함수
  ///
  /// [photos] Firestore에서 가져온 사진 데이터 리스트
  /// [dateField] 날짜 필드명 (기본값: 'created_at')
  ///
  /// Returns: 날짜별로 그룹화된 Map<int, List<Map<String, String?>>>
  /// - key: 일자 (1-31)
  /// - value: 해당 일자의 사진 리스트
  static Map<int, List<Map<String, String?>>> groupPhotosByDay(
    List<Map<String, String?>> photos, {
    String dateField = 'created_at',
  }) {
    final Map<int, List<Map<String, String?>>> photosByDay = {};

    for (final photo in photos) {
      final dateString = photo[dateField] as String?;

      if (dateString != null) {
        try {
          // ISO 문자열을 DateTime으로 파싱
          final dateTime = DateTime.parse(dateString);
          final day = dateTime.day;

          // 해당 날짜에 사진 추가
          photosByDay.putIfAbsent(day, () => []).add(photo);
        } catch (e) {
          // 날짜 파싱 실패 시 건너뛰기
          print('날짜 파싱 오류: $e, dateString: $dateString');
        }
      }
    }

    return photosByDay;
  }

  /// 날짜별로 그룹화된 사진들을 정렬된 날짜 리스트로 변환
  ///
  /// [photosByDay] groupPhotosByDay() 함수의 결과
  ///
  /// Returns: 정렬된 일자 리스트 (1, 2, 3, ...)
  static List<int> getSortedDays(
    Map<int, List<Map<String, String?>>> photosByDay,
  ) {
    return photosByDay.keys.toList()..sort();
  }

  /// 특정 달의 시작일과 마지막일을 ISO 문자열로 반환
  ///
  /// [year] 년도
  /// [month] 월 (1-12)
  ///
  /// Returns: Map<String, String> {'start': '2025-08-01T00:00:00.000Z', 'end': '2025-08-31T23:59:59.999Z'}
  static Map<String, String> getMonthDateRange(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0); // 다음 달 0일 = 이번 달 마지막일

    return {
      'start': startDate.toIso8601String(),
      'end': endDate.toIso8601String(),
    };
  }

  /// ISO 문자열에서 일자만 추출
  ///
  /// [dateString] ISO 형식의 날짜 문자열
  ///
  /// Returns: 일자 (1-31) 또는 null (파싱 실패 시)
  static int? extractDayFromString(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return dateTime.day;
    } catch (e) {
      print('날짜 파싱 오류: $e');
      return null;
    }
  }
}
