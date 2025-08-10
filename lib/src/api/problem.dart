import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../models/problem.dart';
import 'util/core/api_client.dart';

/// 클라이밍 문제 관련 API 호출 함수들
class ProblemApi {
  static final ApiClient _client = ApiClient.instance;

  /// 문제 목록 조회
  static Future<List<Problem>> getProblems({
    int? gymId,
    int? gymAreaId,
    String? localLevel,
    String? holdColor,
    String? problemTier,
    String? activeStatus,
  }) async {
    final queryParams = <String, dynamic>{
      if (gymId != null) 'gymId': gymId,
      if (gymAreaId != null) 'gymAreaId': gymAreaId,
      if (localLevel != null) 'localLevel': localLevel,
      if (holdColor != null) 'holdColor': holdColor,
      if (problemTier != null) 'problemTier': problemTier,
      if (activeStatus != null) 'activeStatus': activeStatus,
    };

    return _client.get<List<Problem>>(
      '/api/problems',
      queryParameters: queryParams,
      fromJson: (data) => (data as List)
          .map((item) => Problem.fromJson(item as Map<String, dynamic>))
          .toList(),
      logContext: 'ProblemApi',
    );
  }

  /// 특정 클라이밍장의 문제 목록 조회
  static Future<List<Problem>> getProblemsByGymId(int gymId) async {
    return getProblems(gymId: gymId);
  }

  /// 특정 문제 상세 정보 조회
  static Future<Problem> getProblemById(String problemId) async {
    return _client.get<Problem>(
      '/api/problems/$problemId',
      fromJson: (data) => Problem.fromJson(data as Map<String, dynamic>),
      logContext: 'ProblemApi',
    );
  }

  /// 문제 생성
  static Future<void> createProblem({
    required int gymAreaId,
    required String localLevelColor, // 색상 문자열
    required String holdColor, // 색상 문자열
    required File imageFile,
  }) async {
    final dio = _client.dio;

    final requestJson = {
      'gymAreaId': gymAreaId,
      'localLevel': localLevelColor,
      'holdColor': holdColor,
    };

    // request를 application/json 파트로 전송
    final requestPart = MultipartFile.fromString(
      jsonEncode(requestJson),
      filename: 'request.json',
      contentType: MediaType('application', 'json'),
    );

    // 파일 Content-Type 결정 (png 또는 jpeg)
    final lower = imageFile.path.toLowerCase();
    String subtype = 'jpeg';
    if (lower.endsWith('.png')) subtype = 'png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) subtype = 'jpeg';

    final imagePart = await MultipartFile.fromFile(
      imageFile.path,
      filename: imageFile.uri.pathSegments.isNotEmpty
          ? imageFile.uri.pathSegments.last
          : 'problem.$subtype',
      contentType: MediaType('image', subtype),
    );

    final formData = FormData.fromMap({
      'request': requestPart,
      'problemImage': imagePart,
    });

    try {
      await dio.post(
        '/api/problems',
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      throw Exception('문제 등록 실패(${e.response?.statusCode}): ${body ?? e.message}');
    }
  }
} 