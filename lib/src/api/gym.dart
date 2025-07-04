import 'dart:developer' as developer;
import 'util/api_client.dart';
import '../models/gym.dart';

/// 클라이밍장 관련 API 호출 함수들
class GymApi {
  static final _dio = ApiClient.instance.dio;

  /// 모든 클라이밍장 목록 조회
  static Future<List<Gym>> getAllGyms() {
    developer.log('클라이밍장 목록 조회 시작', name: 'GymApi');

    return _dio.get('/api/gyms')
      .then((response) => response.data as ApiResponse<dynamic>)
      .then((apiResponse) {
        if (!apiResponse.success || apiResponse.data == null) {
          throw Exception(apiResponse.error ?? '클라이밍장 목록 조회 실패');
        }
        return apiResponse.data as List<dynamic>;
      })
      .then((data) => data
          .map((gymJson) => Gym.fromJson(gymJson as Map<String, dynamic>))
          .toList())
      .then((gymList) {
        developer.log('클라이밍장 ${gymList.length}개 조회 성공', name: 'GymApi');
        return gymList;
      })
      .catchError((e) {
        developer.log('클라이밍장 목록 조회 중 예외 발생: $e', name: 'GymApi');
        throw Exception('클라이밍장 목록을 불러올 수 없습니다: $e');
      });
  }

  /// 특정 클라이밍장 상세 정보 조회
  static Future<Gym> getGymById(int gymId) {
    developer.log('클라이밍장 상세 정보 조회 시작 - ID: $gymId', name: 'GymApi');

    return _dio.get('/api/gyms/$gymId')
      .then((response) => response.data as ApiResponse<dynamic>)
      .then((apiResponse) {
        if (!apiResponse.success || apiResponse.data == null) {
          throw Exception(apiResponse.error ?? '클라이밍장 상세 정보 조회 실패');
        }
        return apiResponse.data as Map<String, dynamic>;
      })
      .then((data) {
        final gym = Gym.fromJson(data);
        developer.log('클라이밍장 상세 정보 조회 성공 - ${gym.name}', name: 'GymApi');
        return gym;
      })
      .catchError((e) {
        developer.log('클라이밍장 상세 정보 조회 중 예외 발생: $e', name: 'GymApi');
        throw Exception('클라이밍장 정보를 불러올 수 없습니다: $e');
      });
  }

  /// 위치 기반 클라이밍장 검색 (거리순 정렬됨)
  static Future<List<Gym>> searchNearbyGyms({
    required double latitude,
    required double longitude,
  }) {
    developer.log('위치 기반 클라이밍장 검색 시작 - Lat: $latitude, Lng: $longitude', name: 'GymApi');

    return _dio.get(
      '/api/gyms',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
      },
    )
      .then((response) => response.data as ApiResponse<dynamic>)
      .then((apiResponse) {
        if (!apiResponse.success || apiResponse.data == null) {
          throw Exception(apiResponse.error ?? '위치 기반 클라이밍장 검색 실패');
        }
        return apiResponse.data as List<dynamic>;
      })
      .then((data) => data
          .map((gymJson) => Gym.fromJson(gymJson as Map<String, dynamic>))
          .toList())
      .then((gymList) {
        developer.log('위치 기반 클라이밍장 ${gymList.length}개 검색 성공', name: 'GymApi');
        return gymList;
      })
      .catchError((e) {
        developer.log('위치 기반 클라이밍장 검색 중 예외 발생: $e', name: 'GymApi');
        throw Exception('주변 클라이밍장을 찾을 수 없습니다: $e');
      });
  }

  /// 키워드로 클라이밍장 검색
  static Future<List<Gym>> searchGymsByKeyword(String keyword) {
    developer.log('키워드로 클라이밍장 검색 시작 - 키워드: $keyword', name: 'GymApi');

    // 빈 키워드면 모든 데이터 반환
    if (keyword.trim().isEmpty) {
      return getAllGyms();
    }

    return _dio.get(
      '/api/gyms',
      queryParameters: {
        'keyword': keyword.trim(),
      },
    )
      .then((response) => response.data as ApiResponse<dynamic>)
      .then((apiResponse) {
        if (!apiResponse.success || apiResponse.data == null) {
          throw Exception(apiResponse.error ?? '키워드 검색 실패');
        }
        return apiResponse.data as List<dynamic>;
      })
      .then((data) => data
          .map((gymJson) => Gym.fromJson(gymJson as Map<String, dynamic>))
          .toList())
      .then((gymList) {
        developer.log('키워드 검색 ${gymList.length}개 결과', name: 'GymApi');
        return gymList;
      })
      .catchError((e) {
        developer.log('키워드 검색 중 예외 발생: $e', name: 'GymApi');
        throw Exception('클라이밍장 검색에 실패했습니다: $e');
      });
  }

  /// 클라이밍장 이름으로 검색 (키워드 검색의 별칭)
  static Future<List<Gym>> searchGymsByName(String query) async {
    return await searchGymsByKeyword(query);
  }
} 