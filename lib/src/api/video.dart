import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:light_compressor/light_compressor.dart' as compressor;
import 'util/core/api_client.dart';
import 'util/core/request_body_builder.dart';
import 'util/auth/user_identity.dart';
import '../models/video.dart';

/// 업로드 응답 모델
class VideoUploadResponse {
  final String videoId;
  final String presignedUrl;

  VideoUploadResponse({required this.videoId, required this.presignedUrl});

  factory VideoUploadResponse.fromJson(Map<String, dynamic> json) {
    return VideoUploadResponse(
      videoId: json['videoId'] as String,
      presignedUrl: json['presignedUrl'] as String,
    );
  }
}

/// 영상 관련 API 호출 함수들
class VideoApi {
  static final _apiClient = ApiClient.instance;

  /// 업로드 가능한 최대 파일 크기 (100MB)
  static const _maxUploadSize = 100 * 1024 * 1024;

  /// 현재 사용자의 영상 목록 조회
  static Future<List<Video>> getCurrentUserVideos() async {
    try {
      final String finalNickname =
          await UserIdentity.getOrFetchNickname(logContext: 'VideoApi');
      developer.log(
        '사용자 영상 목록 조회 - nickname: $finalNickname',
        name: 'VideoApi',
      );

      final data = await _apiClient.get<List<dynamic>>(
        '/api/videos/$finalNickname',
        logContext: 'VideoApi',
      );

      final videoList = data
          .map((json) => Video.fromJson(json as Map<String, dynamic>))
          .toList();

      developer.log('영상 목록 조회 성공 - ${videoList.length}개', name: 'VideoApi');
      return videoList;
    } catch (e) {
      developer.log('영상 목록 조회 실패: $e', name: 'VideoApi', error: e);
      throw Exception('영상 목록을 불러올 수 없습니다: $e');
    }
  }

  /// 특정 사용자의 영상 목록 조회
  static Future<List<Video>> getUserVideosByNickname(String nickname) async {
    try {
      developer.log(
        '사용자 영상 목록 조회 - nickname: $nickname',
        name: 'VideoApi',
      );

      final data = await _apiClient.get<List<dynamic>>(
        '/api/videos/$nickname',
        logContext: 'VideoApi',
      );

      final videoList = data
          .map((json) => Video.fromJson(json as Map<String, dynamic>))
          .toList();

      developer.log('영상 목록 조회 성공 - ${videoList.length}개', name: 'VideoApi');
      return videoList;
    } catch (e) {
      developer.log('영상 목록 조회 실패: $e', name: 'VideoApi', error: e);
      throw Exception('영상 목록을 불러올 수 없습니다: $e');
    }
  }

  /// presigned URL 요청
  static Future<VideoUploadResponse> requestUploadUrl({
    required String fileExtension,
    required int fileSize,
  }) async {
    try {
      developer.log(
        'presigned URL 요청 - extension: $fileExtension, size: $fileSize',
        name: 'VideoApi',
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/api/videos/upload',
        data: RequestBodyBuilder()
            .add('fileExtension', fileExtension)
            .add('fileSize', fileSize)
            .build(),
        logContext: 'VideoApi',
      );

      final uploadResponse = VideoUploadResponse.fromJson(response);
      developer.log(
        'presigned URL 요청 성공 - videoId: ${uploadResponse.videoId}',
        name: 'VideoApi',
      );
      return uploadResponse;
    } catch (e) {
      developer.log('presigned URL 요청 실패: $e', name: 'VideoApi', error: e);
      throw Exception('업로드 URL 요청 실패: $e');
    }
  }

  /// S3에 영상 업로드 (별도 Dio 인스턴스 사용)
  static Future<void> uploadVideoToS3({
    required String presignedUrl,
    required String filePath,
    Function(double)? onProgress,
  }) async {
    try {
      developer.log('S3 업로드 시작 - filePath: $filePath', name: 'VideoApi');

      // S3 전용 Dio 인스턴스 (인터셉터 없음, 타임아웃 길게)
      final s3Dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 10),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      final file = File(filePath);
      final fileSize = await file.length();
      final fileExtension = filePath.split('.').last.toLowerCase();

      // 파일 형식에 따른 Content-Type 설정
      const contentTypes = {
        'mp4': 'video/mp4',
        'mov': 'video/quicktime',
        'avi': 'video/x-msvideo',
      };
      final contentType = contentTypes[fileExtension] ?? 'video/mp4';

      // 진행률 로깅 최적화를 위한 변수
      double lastLoggedProgress = 0.0;

      await s3Dio.put(
        presignedUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': fileSize.toString(),
          },
        ),
        onSendProgress: onProgress != null
            ? (sent, total) {
                final progress = sent / total;

                // 진행률이 5% 이상 변했거나 완료되었을 때만 로그 출력
                if (progress - lastLoggedProgress >= 0.05 || progress >= 1.0) {
                  developer.log(
                    '업로드 진행률: ${(progress * 100).toStringAsFixed(1)}%',
                    name: 'VideoApi',
                  );
                  lastLoggedProgress = progress;
                }

                onProgress(progress);
              }
            : null,
      );

      developer.log('S3 업로드 완료', name: 'VideoApi');
    } catch (e) {
      developer.log('S3 업로드 실패: $e', name: 'VideoApi', error: e);
      throw Exception('S3 업로드 실패: $e');
    }
  }

  /// 전체 업로드 프로세스 (압축 + presigned URL 요청 + S3 업로드)
  static Future<String> uploadVideo({
    required String filePath,
    Function(double)? onProgress,
  }) async {
    try {
      // 1. 원본 파일 정보 추출
      final originalFile = File(filePath);
      final originalFileSize = await originalFile.length();
      final fileExtension = filePath.split('.').last.toLowerCase();

      developer.log(
        '영상 업로드 시작 - 원본 파일: ${originalFile.path}, 크기: ${originalFileSize}bytes, 확장자: $fileExtension',
        name: 'VideoApi',
      );

      // 2. 지원 형식 검증 (압축 전에 먼저 확인)
      const supportedFormats = ['mp4', 'mov', 'avi'];
      if (!supportedFormats.contains(fileExtension)) {
        throw Exception(
          '지원하지 않는 파일 형식입니다. (지원 형식: ${supportedFormats.join(', ')})',
        );
      }

      /// TODO: 파일 형식에 따라 처리로직 변경 필요
      // 3. 비디오 압축 (AVI는 지원되지 않아 원본 그대로 업로드)
      String compressedFilePath;
      int compressedFileSize;

      if (fileExtension == 'avi') {
        developer.log('AVI 형식은 압축을 건너뜁니다', name: 'VideoApi');
        compressedFilePath = filePath;
        compressedFileSize = originalFileSize;
      } else {
        developer.log('비디오 압축 시작 (종횡비 완전 보존)', name: 'VideoApi');
        
        final lightCompressor = compressor.LightCompressor();
        final String videoName = 'compressed_${DateTime.now().millisecondsSinceEpoch}.mp4';
        
        final result = await lightCompressor.compressVideo(
          path: filePath,
          videoQuality: compressor.VideoQuality.medium,
          video: compressor.Video(
            videoName: videoName,
            keepOriginalResolution: true, // 종횡비 완전 보존
          ),
          android: compressor.AndroidConfig(isSharedStorage: false),
          ios: compressor.IOSConfig(saveInGallery: false),
        );

        if (result is compressor.OnSuccess) {
          compressedFilePath = result.destinationPath;
          compressedFileSize = await File(compressedFilePath).length();
          
          developer.log(
            '비디오 압축 완료 - 압축된 파일: $compressedFilePath, 크기: ${compressedFileSize}bytes (원본: ${originalFileSize}bytes)',
            name: 'VideoApi',
          );
        } else if (result is compressor.OnFailure) {
          throw Exception('비디오 압축 실패: ${result.message}');
        } else {
          throw Exception('비디오 압축이 취소되었습니다');
        }
      }

      // 4. 압축된 파일 크기 제한 검증
      if (compressedFileSize > _maxUploadSize) {
        throw Exception(
          '압축된 파일 크기가 여전히 큽니다. (최대: ${_maxUploadSize ~/ (1024 * 1024)}MB)',
        );
      }

      // 5. presigned URL 요청 (압축된 파일 정보로)
      // 압축된 파일의 확장자를 사용해 presigned URL을 요청합니다.
      final compressedFileExtension = compressedFilePath
          .split('.')
          .last
          .toLowerCase();
      final uploadResponse = await requestUploadUrl(
        fileExtension: compressedFileExtension,
        fileSize: compressedFileSize,
      );

      // 6. S3 업로드 (압축된 파일로)
      await uploadVideoToS3(
        presignedUrl: uploadResponse.presignedUrl,
        filePath: compressedFilePath,
        onProgress: onProgress,
      );

      developer.log(
        '전체 업로드 프로세스 완료 - videoId: ${uploadResponse.videoId}',
        name: 'VideoApi',
      );
      return uploadResponse.videoId;
    } catch (e) {
      developer.log('영상 업로드 실패: $e', name: 'VideoApi', error: e);
      rethrow;
    }
  }
}
