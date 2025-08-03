import 'dart:developer' as developer;
import '../models/problem.dart';

/// 클라이밍 문제 관련 API 호출 함수들
class ProblemApi {
  /// 클라이밍 문제 목록 조회 (더미 데이터)
  static Future<List<Problem>> getProblems({
    int? gymId,
    String? localLevel,
    String? holdColor,
  }) async {
    // 실제 API 호출 대신 더미 데이터 반환
    await Future.delayed(const Duration(milliseconds: 500)); // 로딩 시뮬레이션
    
    final dummyProblems = [
      // 더클라임 클라이밍 B 홍대점 (gym_id: 1)
      Problem(
        id: 1,
        gymId: 1,
        localLevel: '빨강',
        holdColor: '초록',
        problemRating: 142,
        spotId: 1,
        spotXRatio: 15.5,
        spotYRatio: 20.3,
        imageUrl: 'https://example.com/problem1.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Problem(
        id: 2,
        gymId: 1,
        localLevel: '파랑',
        holdColor: '파랑',
        problemRating: 876,
        spotId: 1,
        spotXRatio: 45.2,
        spotYRatio: 35.7,
        imageUrl: 'https://example.com/problem2.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Problem(
        id: 3,
        gymId: 1,
        localLevel: '초록',
        holdColor: '노랑',
        problemRating: 1542,
        spotId: 1,
        spotXRatio: 75.8,
        spotYRatio: 60.1,
        imageUrl: 'https://example.com/problem3.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Problem(
        id: 4,
        gymId: 1,
        localLevel: '빨강',
        holdColor: '초록',
        problemRating: 89,
        spotId: 2,
        spotXRatio: 25.0,
        spotYRatio: 80.5,
        imageUrl: 'https://example.com/problem4.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Problem(
        id: 5,
        gymId: 1,
        localLevel: '파랑',
        holdColor: '보라',
        problemRating: 1234,
        spotId: 2,
        spotXRatio: 65.3,
        spotYRatio: 40.9,
        imageUrl: 'https://example.com/problem5.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      // 더클라임 클라이밍 일산점 (gym_id: 2)
      Problem(
        id: 6,
        gymId: 2,
        localLevel: '빨강',
        holdColor: '빨강',
        problemRating: 234,
        spotId: 6,
        spotXRatio: 30.7,
        spotYRatio: 25.4,
        imageUrl: 'https://example.com/problem6.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Problem(
        id: 7,
        gymId: 2,
        localLevel: '파랑',
        holdColor: '파랑',
        problemRating: 1567,
        spotId: 7,
        spotXRatio: 55.1,
        spotYRatio: 50.8,
        imageUrl: 'https://example.com/problem7.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Problem(
        id: 8,
        gymId: 2,
        localLevel: '초록',
        holdColor: '노랑',
        problemRating: 2345,
        spotId: 8,
        spotXRatio: 85.9,
        spotYRatio: 70.2,
        imageUrl: 'https://example.com/problem8.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Problem(
        id: 9,
        gymId: 2,
        localLevel: '빨강',
        holdColor: '초록',
        problemRating: 178,
        spotId: 9,
        spotXRatio: 20.4,
        spotYRatio: 15.6,
        imageUrl: 'https://example.com/problem9.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Problem(
        id: 10,
        gymId: 2,
        localLevel: '파랑',
        holdColor: '보라',
        problemRating: 987,
        spotId: 10,
        spotXRatio: 60.8,
        spotYRatio: 45.3,
        imageUrl: 'https://example.com/problem10.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    // 필터링 로직
    List<Problem> filteredProblems = dummyProblems;

    if (gymId != null) {
      filteredProblems = filteredProblems.where((problem) => problem.gymId == gymId).toList();
    }

    if (localLevel != null && localLevel.isNotEmpty) {
      filteredProblems = filteredProblems.where((problem) => problem.localLevel == localLevel).toList();
    }

    if (holdColor != null && holdColor.isNotEmpty) {
      filteredProblems = filteredProblems.where((problem) => problem.holdColor == holdColor).toList();
    }

    developer.log('클라이밍 문제 ${filteredProblems.length}개 조회 성공', name: 'ProblemApi');
    return filteredProblems;
  }

  /// 특정 클라이밍장의 문제 목록 조회
  static Future<List<Problem>> getProblemsByGymId(int gymId) async {
    return await getProblems(gymId: gymId);
  }

  /// 특정 문제 상세 정보 조회 (더미 데이터)
  static Future<Problem?> getProblemById(int problemId) async {
    final problems = await getProblems();
    try {
      return problems.firstWhere((problem) => problem.id == problemId);
    } catch (e) {
      return null;
    }
  }
} 