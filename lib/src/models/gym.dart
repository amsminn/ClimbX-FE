/// 클라이밍장 정보 모델
class Gym {
  final int gymId;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String phoneNumber;
  final String description;
  final String map2DUrl;
  final List<GymArea> gymAreas;

  Gym({
    required this.gymId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.phoneNumber,
    required this.description,
    required this.map2DUrl,
    this.gymAreas = const [],
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    final areas = (json['gymAreas'] as List?) ?? const [];
    return Gym(
      gymId: json['gymId'] ?? 0,
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      description: json['description'] ?? '',
      map2DUrl: (json['map2dImageCdnUrl'] ?? json['map2DUrl'] ?? '') as String,
      gymAreas: areas
          .map((e) => GymArea.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gymId': gymId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phoneNumber': phoneNumber,
      'description': description,
      'map2DUrl': map2DUrl,
      'gymAreas': gymAreas.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Gym(id: $gymId, name: $name, address: $address)';
  }
}

/// 클라이밍장 영역 모델
class GymArea {
  final int areaId;
  final String areaName;
  final String areaImageCdnUrl;

  GymArea({
    required this.areaId,
    required this.areaName,
    required this.areaImageCdnUrl,
  });

  factory GymArea.fromJson(Map<String, dynamic> json) {
    return GymArea(
      areaId: json['areaId'] ?? 0,
      areaName: json['areaName'] ?? '',
      areaImageCdnUrl: json['areaImageCdnUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'areaId': areaId,
      'areaName': areaName,
      'areaImageCdnUrl': areaImageCdnUrl,
    };
  }
}