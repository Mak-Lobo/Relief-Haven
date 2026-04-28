class GeoPointModel {
  final String type;
  final List<double> coordinates;

  const GeoPointModel({
    required this.type,
    required this.coordinates,
  });

  factory GeoPointModel.fromJson(Map<String, dynamic> json) {
    return GeoPointModel(
      type: json['type'] as String? ?? 'Point',
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((value) => (value as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  GeoPointModel copyWith({
    String? type,
    List<double>? coordinates,
  }) {
    return GeoPointModel(
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
    );
  }
}
