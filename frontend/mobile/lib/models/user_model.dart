class UserModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final int phone;
  final String role; // always 'civilian' on mobile
  final DateTime createdAt; // DB-generated — display only, never sent
  final DateTime updatedAt; // DB-generated — display only, never sent

  const UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  // // ── Convenience getters ──────────────────────────────────────────────────
  //
  // String get fullName => '$firstName $lastName';
  //
  // /// Two-letter initials for avatar display (e.g. "JK" for John Kamau)
  // String get initials {
  //   final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
  //   final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
  //   return '$f$l';
  // }

  // ── Serialisation ────────────────────────────────────────────────────────

  /// Deserialises from the UserOut JSON returned by GET /users/{user_id}.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as int,
      role: json['role_user'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Full serialisation — used for local caching only (SharedPreferences).
  /// Never sent to the backend as-is; use toSyncPayload() for POST /users/sync.
  // Map<String, dynamic> toJson() {
  //   return {
  //     'user_id': userId,
  //     'first_name': firstName,
  //     'last_name': lastName,
  //     'email': email,
  //     'phone': phone,
  //     'role_user': role,
  //     'created_at': createdAt.toIso8601String(),
  //     'updated_at': updatedAt.toIso8601String(),
  //   };
  // }

  // ── Sync payload ─────────────────────────────────────────────────────────
  //
  // Sent to POST /users/sync immediately after Supabase Auth signUp succeeds.
  // Maps to backend UserIn: { user_id, first_name, last_name, email_address,
  //                           phone_number, role }
  //
  // Rules enforced here:
  //   - role hardcoded to 'civilian' — mobile users can only self-register as
  //     civilians. Manager/command accounts are created via the web dashboard.
  //   - county_work sent as null on mobile — manager-only field.
  //   - Dates NOT included — the DB generates created_at and updated_at on INSERT.

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'role': 'civilian',
      'county_work': null,
    };
  }

  UserModel copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    int? phone,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // @override
  // String toString() => 'UserModel(userId: $userId, name: $fullName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}
