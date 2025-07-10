import 'dart:typed_data';

class Video {
  final int videoId; // 비디오ID
  final int userId; // 유저ID
  final String videoUrl; // 파일 URL
  final Map<String, dynamic>? videoMetadata; // 비디오 메타데이터 (json, 썸네일 포함)

  Video({
    required this.videoId,
    required this.userId,
    required this.videoUrl,
    this.videoMetadata,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    // 썸네일은 video_metadata['thumbnail']에 Uint8List로 저장
    Map<String, dynamic>? metadata = json['video_metadata'] as Map<String, dynamic>?;
    if (metadata != null && metadata['thumbnail'] != null && metadata['thumbnail'] is List) {
      metadata = Map<String, dynamic>.from(metadata); // 불변 map으로 인한 런타임 에러 방지
      metadata['thumbnail'] = Uint8List.fromList(List<int>.from(metadata['thumbnail'] as List));
    }
    return Video(
      videoId: json['video_id'] as int,
      userId: json['user_id'] as int,
      videoUrl: json['video_url'] as String,
      videoMetadata: metadata,
    );
  }

  Map<String, dynamic> toJson() {
    // 썸네일이 있으면 List<int>로 변환해서 저장
    Map<String, dynamic>? metadata = videoMetadata;
    if (metadata != null &&
        metadata['thumbnail'] != null &&
        metadata['thumbnail'] is Uint8List) {
      metadata = Map<String, dynamic>.from(metadata);
      metadata['thumbnail'] = (metadata['thumbnail'] as Uint8List).toList();
    }
    return {
      'video_id': videoId,
      'user_id': userId,
      'video_url': videoUrl,
      'video_metadata': metadata,
    };
  }
}
