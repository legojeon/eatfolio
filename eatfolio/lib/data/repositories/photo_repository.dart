import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/date_utils.dart';

/// 사진 데이터를 관리하는 리포지토리 클래스
class PhotoRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 사용자별 사진 개수를 가져오는 스트림
  static Stream<int> getUserPhotoCount(String userId) {
    return _firestore
        .collection('Photos')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// 사용자별 사진 리스트를 가져오는 스트림 (최신 순)
  static Stream<List<DocumentSnapshot>> getUserPhotos(String userId) {
    return _firestore
        .collection('Photos')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  /// 특정 사진의 상세 정보를 가져오는 함수
  static Future<Map<String, dynamic>?> getPhotoDetail(String recordId) async {
    try {
      final doc = await _firestore.collection('Photos').doc(recordId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting photo detail: $e');
      return null;
    }
  }

  /// 특정 사진의 FoodCard용 요약 정보를 가져오는 함수
  static Future<Map<String, dynamic>?> getFoodSummary(String recordId) async {
    try {
      final doc = await _firestore.collection('Photos').doc(recordId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'food_name': data['food_name'],
          'meal_time': data['meal_time'],
          'food_category': data['food_category'],
          'rating': data['rating'],
          'image_path': data['image_path'], // ✅ image_path 추가
        };
      }
      return null;
    } catch (e) {
      print('Error getting food summary: $e');
      return null;
    }
  }

  /// 특정 달의 사진을 가져오는 함수 (DayCard용 형식) - Stream 버전
  static Stream<List<Map<String, String?>>> getPhotosByMonth(
    String userId,
    int year,
    int month,
  ) {
    // DateUtils를 사용해서 날짜 범위 계산
    final dateRange = PhotoDateUtils.getMonthDateRange(year, month);
    final startDateString = dateRange['start']!;
    final endDateString = dateRange['end']!;

    print(
      '🔍 PhotoRepository: 쿼리 조건 - userId: $userId, startDate: $startDateString, endDate: $endDateString',
    );

    return _firestore
        .collection('Photos')
        .where('user_id', isEqualTo: userId)
        .where('created_at', isGreaterThanOrEqualTo: startDateString)
        .where('created_at', isLessThanOrEqualTo: endDateString)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          print('🔍 PhotoRepository: 쿼리 결과 - ${snapshot.docs.length}개 문서');
          return snapshot.docs
              .map(
                (doc) => {
                  'imagePath': doc['image_path'] as String?,
                  'recordId': doc['record_id'] as String?,
                  'created_at': doc['created_at'] as String?,
                },
              )
              .toList();
        });
  }

  /// 특정 달의 사진을 가져오는 함수 (DayCard용 형식) - Future 버전
  static Future<List<Map<String, String?>>> getPhotosByMonthOnce(
    String userId,
    int year,
    int month,
  ) async {
    // DateUtils를 사용해서 날짜 범위 계산
    final dateRange = PhotoDateUtils.getMonthDateRange(year, month);
    final startDateString = dateRange['start']!;
    final endDateString = dateRange['end']!;

    print(
      '🔍 PhotoRepository: Future 쿼리 조건 - userId: $userId, startDate: $startDateString, endDate: $endDateString',
    );

    final snapshot = await _firestore
        .collection('Photos')
        .where('user_id', isEqualTo: userId)
        .where('created_at', isGreaterThanOrEqualTo: startDateString)
        .where('created_at', isLessThanOrEqualTo: endDateString)
        .orderBy('created_at', descending: true)
        .get();

    print('🔍 PhotoRepository: Future 쿼리 결과 - ${snapshot.docs.length}개 문서');
    return snapshot.docs
        .map(
          (doc) => {
            'imagePath': doc['image_path'] as String?,
            'recordId': doc['record_id'] as String?,
            'created_at': doc['created_at'] as String?,
          },
        )
        .toList();
  }

  /// 특정 식사 시간의 사진을 가져오는 함수
  static Stream<List<DocumentSnapshot>> getPhotosByMealTime(
    String userId,
    String mealTime,
  ) {
    return _firestore
        .collection('Photos')
        .where('user_id', isEqualTo: userId)
        .where('meal_time', isEqualTo: mealTime)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  /// 사진 삭제 함수
  static Future<bool> deletePhoto(String recordId) async {
    try {
      await _firestore.collection('Photos').doc(recordId).delete();
      return true;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }

  /// 사진 업데이트 함수
  static Future<bool> updatePhoto(
    String recordId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      await _firestore.collection('Photos').doc(recordId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating photo: $e');
      return false;
    }
  }
}
