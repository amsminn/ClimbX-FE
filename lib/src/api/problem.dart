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
        problemId: '550e8400-e29b-41d4-a716-446655440001',
        gymId: 1,
        gymAreaId: 1,
        gymAreaName: '메인홀',
        localLevel: '빨강',
        holdColor: '초록',
        problemRating: 142,
        problemImageCdnUrl: 'https://example.com/problem1.jpg',
        activeStatus: 'ACTIVE',
        createdAt: DateTime.now(),
      ),
      Problem(
        problemId: '550e8400-e29b-41d4-a716-446655440002',
        gymId: 1,
        gymAreaId: 1,
        gymAreaName: '메인홀',
        localLevel: '파랑',
        holdColor: '파랑',
        problemRating: 876,
        problemImageCdnUrl: 'https://example.com/problem2.jpg',
        activeStatus: 'ACTIVE',
        createdAt: DateTime.now(),
      ),
      Problem(
        problemId: '550e8400-e29b-41d4-a716-446655440003',
        gymId: 1,
        gymAreaId: 2,
        gymAreaName: '보조홀',
        localLevel: '초록',
        holdColor: '노랑',
        problemRating: 1542,
        problemImageCdnUrl: 'https://example.com/problem3.jpg',
        activeStatus: 'ACTIVE',
        createdAt: DateTime.now(),
      ),
      Problem(
        problemId: '550e8400-e29b-41d4-a716-446655440004',
        gymId: 1,
        gymAreaId: 2,
        gymAreaName: '보조홀',
        localLevel: '빨강',
        holdColor: '초록',
        problemRating: 89,
        problemImageCdnUrl: 'https://example.com/problem4.jpg',
        activeStatus: 'ACTIVE',
        createdAt: DateTime.now(),
      ),
      Problem(
        problemId: '550e8400-e29b-41d4-a716-446655440005',
        gymId: 1,
        gymAreaId: 3,
        gymAreaName: '연습홀',
        localLevel: '파랑',
        holdColor: '보라',
        problemRating: 1234,
        problemImageCdnUrl: 'https://example.com/problem5.jpg',
        activeStatus: 'ACTIVE',
        createdAt: DateTime.now(),
      ),
      // 더클라임 클라이밍 일산점 (gym_id: 2)
      Problem(
        problemId: '550e8400-e29b-41d4-a716-446655440006',
        gymId: 2,
        gymAreaId: 4,
        gymAreaName: '메인홀',
        localLevel: '빨강',
        holdColor: '빨강',
        problemRating: 234,
        problemImageCdnUrl: 'https://example.com/problem6.jpg',
        activeStatus: 'ACTIVE',
        createdAt: DateTime.now(),
      ),
      Problem(
        problemId: '550e8400-e29b-41d4-a716-446655440007',
        gymId: 2,
        gymAreaId: 4,
        gymAreaName: '메인홀',
        localLevel: '파랑',
        holdColor: '파랑',
        problemRating: 1567,
        problemImageCdnUrl: 'https://example.com/problem7.jpg',
        activeStatus: 'ACTIVE',
        createdAt: DateTime.now(),
      ),
      Problem(
        problemId: '550e8400-e29b-41d4-a716-446655440008',
        gymId: 2,
        gymAreaId: 5,
        gymAreaName: '보조홀',
        localLevel: '초록',
        holdColor: '노랑',
        problemRating: 2345,
        problemImageCdnUrl: 'https://example.com/problem8.jpg',
        activeStatus: 'ACTIVE',
        createdAt: DateTime.now(),
      ),
      Problem(
        problemId: '550e8400-e29b-41d4-a716-446655440009',
        gymId: 2,
        gymAreaId: 5,
        gymAreaName: '보조홀',
        localLevel: '빨강',
        holdColor: '초록',
        problemRating: 178,
        problemImageCdnUrl: 'https://example.com/problem9.jpg',
        activeStatus: 'ACTIVE',
        createdAt: DateTime.now(),
      ),
      Problem(
        problemId: '550e8400-e29b-41d4-a716-446655440010',
        gymId: 2,
        gymAreaId: 6,
        gymAreaName: '연습홀',
        localLevel: '파랑',
        holdColor: '보라',
        problemRating: 987,
        problemImageCdnUrl: 'https://example.com/problem10.jpg',
        activeStatus: 'ACTIVE',
        createdAt: DateTime.now(),
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
  static Future<Problem?> getProblemById(String problemId) async {
    final problems = await getProblems();
    try {
      return problems.firstWhere((problem) => problem.problemId == problemId);
    } catch (e) {
      return null;
    }
  }
} 