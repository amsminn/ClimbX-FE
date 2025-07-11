import 'dart:developer' as developer;
import 'util/core/api_client.dart';
import '../models/gym.dart';

/// 클라이밍장 관련 API 호출 함수들
class GymApi {
  static final _apiClient = ApiClient.instance;

  /// 모든 클라이밍장 목록 조회
  static Future<List<Gym>> getAllGyms() async {
    try {
      final data = await _apiClient.get<List<dynamic>>(
        '/api/gyms/search',
        logContext: 'GymApi',
      );
      
      final gymList = data
          .map((gymJson) => Gym.fromJson(gymJson as Map<String, dynamic>))
          .toList();
      
      developer.log('클라이밍장 ${gymList.length}개 조회 성공', name: 'GymApi');
      return gymList;
    } catch (e) {
      throw Exception('클라이밍장 목록을 불러올 수 없습니다: $e');
    }
  }

  /// 특정 클라이밍장 상세 정보 조회
  static Future<Gym> getGymById(int gymId) async {
    try {
      return await _apiClient.get<Gym>(
        '/api/gyms/$gymId',
        fromJson: (data) => Gym.fromJson(data as Map<String, dynamic>),
        logContext: 'GymApi',
      );
    } catch (e) {
      throw Exception('클라이밍장 정보를 불러올 수 없습니다: $e');
    }
  }

  /// 위치 기반 클라이밍장 검색 (거리순 정렬됨)
  static Future<List<Gym>> searchNearbyGyms({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final data = await _apiClient.get<List<dynamic>>(
        '/api/gyms',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
        logContext: 'GymApi',
      );

      final gymList = data
          .map((gymJson) => Gym.fromJson(gymJson as Map<String, dynamic>))
          .toList();
      
      developer.log('위치 기반 클라이밍장 ${gymList.length}개 검색 성공', name: 'GymApi');
      return gymList;
    } catch (e) {
      throw Exception('주변 클라이밍장을 찾을 수 없습니다: $e');
    }
  }

  /// 키워드로 클라이밍장 검색
  static Future<List<Gym>> searchGymsByKeyword(String keyword) async {
    try {
      // 빈 키워드면 모든 데이터 반환
      if (keyword.trim().isEmpty) {
        return getAllGyms();
      }

      final data = await _apiClient.get<List<dynamic>>(
        '/api/gyms',
        queryParameters: {
          'keyword': keyword.trim(),
        },
        logContext: 'GymApi',
      );

      final gymList = data
          .map((gymJson) => Gym.fromJson(gymJson as Map<String, dynamic>))
          .toList();
      
      developer.log('키워드 검색 ${gymList.length}개 결과', name: 'GymApi');
      return gymList;
    } catch (e) {
      throw Exception('클라이밍장 검색에 실패했습니다: $e');
    }
  }

  /// 클라이밍장 이름으로 검색 (키워드 검색의 별칭)
  static Future<List<Gym>> searchGymsByName(String query) async {
    return await searchGymsByKeyword(query);
  }
} 