import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';
part 'video.g.dart';

/// 영상 처리 상태
enum VideoStatus { pending, processing, completed, failed }

class VideoStatusConverter implements JsonConverter<VideoStatus, String> {
  const VideoStatusConverter();
  @override
  VideoStatus fromJson(String json) {
    switch (json.toUpperCase()) {
      case 'PENDING':
        return VideoStatus.pending;
      case 'PROCESSING':
        return VideoStatus.processing;
      case 'COMPLETED':
        return VideoStatus.completed;
      case 'FAILED':
        return VideoStatus.failed;
      default:
        return VideoStatus.pending;
    }
  }

  @override
  String toJson(VideoStatus object) {
    switch (object) {
      case VideoStatus.pending:
        return 'PENDING';
      case VideoStatus.processing:
        return 'PROCESSING';
      case VideoStatus.completed:
        return 'COMPLETED';
      case VideoStatus.failed:
        return 'FAILED';
    }
  }
}

/// 영상 정보 모델 (백엔드 응답 + 클라이언트 전용 필드)
@freezed
abstract class Video with _$Video {
  const factory Video({
    String? videoId,
    String? thumbnailCdnUrl,
    String? hlsCdnUrl,
    @VideoStatusConverter() @Default(VideoStatus.pending) VideoStatus status,
    int? durationSeconds,
    required DateTime createdAt,
    // 클라이언트 전용 필드
    String? localPath,
    double? uploadProgress,
    @Default(false) bool isUploading,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  const Video._();

  /// 로컬 파일에서 Video 객체 생성 (업로드 전)
  factory Video.fromLocalFile(String filePath) => Video(
        status: VideoStatus.pending,
        createdAt: DateTime.now(),
        localPath: filePath,
        isUploading: false,
      );

  /// JSON 직렬화는 Freezed/json_serializable 생성 코드 사용

  // === 편의 메서드들 ===

  /// 영상 처리 완료 여부
  bool get isCompleted => status == VideoStatus.completed;

  /// 영상 처리 대기 중 여부
  bool get isPending => status == VideoStatus.pending;

  /// 영상 처리 실패 여부
  bool get isFailed => status == VideoStatus.failed;

  /// 처리 중 여부
  bool get isProcessing => status == VideoStatus.processing;

  /// 재생 가능한 URL이 있는지 확인
  bool get hasValidUrl => hlsCdnUrl != null && hlsCdnUrl!.isNotEmpty;

  /// 썸네일이 있는지 확인
  bool get hasThumbnail => thumbnailCdnUrl != null && thumbnailCdnUrl!.isNotEmpty;

  /// 표시할 파일명 생성
  String get displayName {
    if (localPath != null) {
      return localPath!.split('/').last;
    }
    return '영상 ${createdAt.toIso8601String().split('T')[0]}';
  }

  /// 썸네일 위젯 생성
  Widget getThumbnailWidget({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (hasThumbnail) {
      return Image.network(
        thumbnailCdnUrl!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _getDefaultIcon(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        },
      );
    } else {
      return Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: _getDefaultIcon(),
      );
    }
  }

  /// 재생 시간을 MM:SS 형식으로 변환
  String get formattedDuration {
    if (durationSeconds == null) return '';

    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 기본 아이콘 위젯
  Widget _getDefaultIcon() {
    return const Icon(
      Icons.video_file_outlined,
      size: 32,
      color: Colors.grey,
    );
  }

  // copyWith는 Freezed가 생성

  @override
  String toString() =>
      'Video(videoId: $videoId, status: ${status.name}, localPath: $localPath, isUploading: $isUploading)';
}
