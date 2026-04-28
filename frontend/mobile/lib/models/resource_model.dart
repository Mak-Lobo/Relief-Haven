class ResourceModel {
  final String resourceId;
  final String shelterId;
  final bool food;
  final bool water;
  final String? addNotes;
  final DateTime updatedAt;

  ResourceModel({
    required this.resourceId,
    required this.shelterId,
    required this.food,
    required this.water,
    this.addNotes,
    required this.updatedAt,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      resourceId: json['resource_id'] as String,
      shelterId: json['shelter_id'] as String,
      food: json['food'] as bool,
      water: json['water'] as bool,
      addNotes: json['add_notes'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resource_id': resourceId,
      'shelter_id': shelterId,
      'food': food,
      'water': water,
      'add_notes': addNotes,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ResourceModel copyWith({
    String? resourceId,
    String? shelterId,
    bool? food,
    bool? water,
    String? addNotes,
    DateTime? updatedAt,
  }) {
    return ResourceModel(
      resourceId: resourceId ?? this.resourceId,
      shelterId: shelterId ?? this.shelterId,
      food: food ?? this.food,
      water: water ?? this.water,
      addNotes: addNotes ?? this.addNotes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
