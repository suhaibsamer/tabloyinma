class Mosque {
  final String name;
  final double latitude;
  final double longitude;
  final String placeId;
  final String? address;

  Mosque({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.placeId,
    this.address,
  });

  factory Mosque.fromJson(Map<String, dynamic> json) {
    return Mosque(
      name: json['name'] ?? 'Mosque',
      latitude: json['geometry']['location']['lat'].toDouble(),
      longitude: json['geometry']['location']['lng'].toDouble(),
      placeId: json['place_id'],
      address: json['vicinity'],
    );
  }
}

