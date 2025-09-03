import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym.freezed.dart';
part 'gym.g.dart';

/// 클라이밍장 정보 모델
@Freezed(fromJson: true, toJson: true)
abstract class Gym with _$Gym {
  const factory Gym({
    @Default(0) int gymId,
    @Default('') String name,
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    @Default('') String address,
    @Default('') String phoneNumber,
    @Default('') String description,
    @Default('') String map2dImageCdnUrl,
    @Default(<GymArea>[]) List<GymArea> gymAreas,
  }) = _Gym;

  factory Gym.fromJson(Map<String, dynamic> json) => _$GymFromJson(json);
}

/// 클라이밍장 영역 모델
@Freezed(fromJson: true, toJson: true)
abstract class GymArea with _$GymArea {
  const factory GymArea({
    @Default(0) int areaId,
    @Default('') String areaName,
    @Default('') String areaImageCdnUrl,
  }) = _GymArea;

  factory GymArea.fromJson(Map<String, dynamic> json) => _$GymAreaFromJson(json);
}
