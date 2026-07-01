class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'tenant' or 'landlord'
  final String? landlordId; // for tenants, which landlord they belong to
  final String? inviteCode; // for landlords, their invite code
  final String? photoUrl; // optional profile photo URL
  final bool isVerified;
  final String? password; // Only for demo local auth. Do NOT store plaintext in production.
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.landlordId,
    this.inviteCode,
    this.photoUrl,
    this.isVerified = true,
    this.password,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic field) {
      if (field == null) return '';
      if (field is String) return field;
      if (field is Map) return (field['_id'] ?? field['id'] ?? '').toString();
      return field.toString();
    }

    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'tenant',
      landlordId: json['landlordId'] == null ? null : extractId(json['landlordId']),
      inviteCode: json['inviteCode'],
      photoUrl: json['photoUrl'] as String?,
      isVerified: json['isVerified'] == null ? true : json['isVerified'] as bool,
      password: json['password'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'landlordId': landlordId,
      'inviteCode': inviteCode,
      'photoUrl': photoUrl,
      'isVerified': isVerified,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
