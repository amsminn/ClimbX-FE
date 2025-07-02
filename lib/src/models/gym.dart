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

  Gym({
    required this.gymId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.phoneNumber,
    required this.description,
    required this.map2DUrl,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      gymId: json['gymId'] ?? 0,
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      description: json['description'] ?? '',
      map2DUrl: json['map2DUrl'] ?? '',
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
    };
  }

  @override
  String toString() {
    return 'Gym(id: $gymId, name: $name, address: $address)';
  }
} 