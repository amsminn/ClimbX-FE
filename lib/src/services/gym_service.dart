import 'dart:developer' as developer;
import 'api_client.dart';
import '../models/gym.dart';

/// 클라이밍장 관련 API 호출 서비스
class GymService {
  static final _apiClient = ApiClient.instance;

  /// 모든 클라이밍장 목록 조회
  static Future<List<Gym>?> getAllGyms() async {
    try {
      developer.log('클라이밍장 목록 조회 시작', name: 'GymService');

      final response = await _apiClient.get<List<dynamic>>(
        '/api/gyms',
      );

      // 응답 실패 시 바로 리턴
      if (!response.success || response.data == null) {
        developer.log('클라이밍장 목록 조회 실패: ${response.error}', name: 'GymService');
        return null;
      }

      final gymList = response.data!
          .map((gymJson) => Gym.fromJson(gymJson as Map<String, dynamic>))
          .toList();
      
      developer.log('클라이밍장 ${gymList.length}개 조회 성공', name: 'GymService');
      return gymList;
    } catch (e) {
      developer.log('클라이밍장 목록 조회 중 예외 발생: $e', name: 'GymService');
      return null;
    }
  }

  /// 특정 클라이밍장 상세 정보 조회
  static Future<Gym?> getGymById(int gymId) async {
    try {
      developer.log('클라이밍장 상세 정보 조회 시작 - ID: $gymId', name: 'GymService');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/gyms/$gymId',
        fromJson: (json) => json,
      );

      // 응답 실패 시 바로 리턴
      if (!response.success || response.data == null) {
        developer.log('클라이밍장 상세 정보 조회 실패: ${response.error}', name: 'GymService');
        return null;
      }

      final gym = Gym.fromJson(response.data!);
      developer.log('클라이밍장 상세 정보 조회 성공 - ${gym.name}', name: 'GymService');
      return gym;
    } catch (e) {
      developer.log('클라이밍장 상세 정보 조회 중 예외 발생: $e', name: 'GymService');
      return null;
    }
  }

  /// 위치 기반 클라이밍장 검색 (거리순 정렬됨)
  static Future<List<Gym>?> searchNearbyGyms({
    required double latitude,
    required double longitude,
  }) async {
    try {
      developer.log('위치 기반 클라이밍장 검색 시작 - Lat: $latitude, Lng: $longitude', name: 'GymService');

      final response = await _apiClient.get<List<dynamic>>(
        '/api/gyms',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      // 응답 실패 시 바로 리턴
      if (!response.success || response.data == null) {
        developer.log('위치 기반 클라이밍장 검색 실패: ${response.error}', name: 'GymService');
        return null;
      }

      final gymList = response.data!
          .map((gymJson) => Gym.fromJson(gymJson as Map<String, dynamic>))
          .toList();
      
      developer.log('위치 기반 클라이밍장 ${gymList.length}개 검색 성공', name: 'GymService');
      return gymList;
    } catch (e) {
      developer.log('위치 기반 클라이밍장 검색 중 예외 발생: $e', name: 'GymService');
      return null;
    }
  }

  /// 키워드로 클라이밍장 검색
  static Future<List<Gym>?> searchGymsByKeyword(String keyword) async {
    try {
      developer.log('키워드로 클라이밍장 검색 시작 - 키워드: $keyword', name: 'GymService');

      // 빈 키워드면 모든 데이터 반환
      if (keyword.trim().isEmpty) {
        return await getAllGyms();
      }

      final response = await _apiClient.get<List<dynamic>>(
        '/api/gyms',
        queryParameters: {
          'keyword': keyword.trim(),
        },
      );

      // 응답 실패 시 바로 리턴
      if (!response.success || response.data == null) {
        developer.log('키워드 검색 실패: ${response.error}', name: 'GymService');
        return null;
      }

      final gymList = response.data!
          .map((gymJson) => Gym.fromJson(gymJson as Map<String, dynamic>))
          .toList();
      
      developer.log('키워드 검색 ${gymList.length}개 결과', name: 'GymService');
      return gymList;
    } catch (e) {
      developer.log('키워드 검색 중 예외 발생: $e', name: 'GymService');
      return null;
    }
  }

  /// searchGymsByName을 searchGymsByKeyword로 리다이렉트 (호환성)
  static Future<List<Gym>?> searchGymsByName(String query) async {
    return await searchGymsByKeyword(query);
  }
} 