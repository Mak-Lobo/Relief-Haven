import 'geo_point_model.dart';

class ShelterModel {
  final String shelterId;
  final String name;
  final String subcounty;
  final String county;
  final GeoPointModel? location;

  ShelterModel({
    required this.shelterId,
    required this.name,
    required this.subcounty,
    required this.county,
    this.location,
  });

  factory ShelterModel.fromJson(Map<String, dynamic> json) {
    final locationJson = json['location'];
    return ShelterModel(
      shelterId: json['shelter_id'] as String,
      name: json['name'] as String,
      subcounty: json['subcounty'] as String,
      county: json['county'] as String,
      location: locationJson is Map<String, dynamic>
          ? GeoPointModel.fromJson(locationJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shelter_id': shelterId,
      'name': name,
      'subcounty': subcounty,
      'county': county,
      'location': location?.toJson(),
    };
  }

  ShelterModel copyWith({
    String? shelterId,
    String? name,
    String? subcounty,
    String? county,
    GeoPointModel? location,
  }) {
    return ShelterModel(
      shelterId: shelterId ?? this.shelterId,
      name: name ?? this.name,
      subcounty: subcounty ?? this.subcounty,
      county: county ?? this.county,
      location: location ?? this.location,
    );
  }
}
