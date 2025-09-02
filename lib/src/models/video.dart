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
  final String? videoId;           // 업로드 후 받을 ID
  final String? thumbnailCdnUrl;   // 백엔드 생성 썸네일 URL
  final String? hlsCdnUrl;         // HLS 스트리밍 URL
  final VideoStatus status;        // 영상 처리 상태
  final int? durationSeconds;      // 영상 길이 (초)
  final DateTime createdAt;        // 생성 시간

  // 클라이언트 전용 필드들 (서버에 저장되지 않음)
  final String? localPath;         // 업로드 전 로컬 파일 경로
  final double? uploadProgress;    // 업로드 진행률 (0.0 ~ 1.0)
  final bool isUploading;          // 업로드 중 여부

  /// 로컬 파일에서 Video 객체 생성 (업로드 전)
  factory Video.fromLocalFile(String filePath) => Video(
        status: VideoStatus.pending,
        createdAt: DateTime.now(),
        localPath: filePath,
        isUploading: false,
      );

  /// JSON 직렬화 (백엔드 필드만)
  Map<String, dynamic> toJson() => _$VideoToJson(this);

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
  String toString() {
    return 'Video(videoId: $videoId, status: ${status.value}, localPath: $localPath, isUploading: $isUploading)';
  }
}
