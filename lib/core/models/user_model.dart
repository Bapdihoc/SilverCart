import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role; // 'elderly' or 'family'
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? avatar;
  final List<String>? familyMembers; // For family role, list of elderly IDs they manage
  final String? managedBy; // For elderly role, ID of family member who manages them

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.avatar,
    this.familyMembers,
    this.managedBy,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? avatar,
    List<String>? familyMembers,
    String? managedBy,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      avatar: avatar ?? this.avatar,
      familyMembers: familyMembers ?? this.familyMembers,
      managedBy: managedBy ?? this.managedBy,
    );
  }

  bool get isElderly => role == 'elderly';
  bool get isFamily => role == 'family';

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }
}

@JsonSerializable()
class FamilyLoginRequest {
  final String phone;
  final String password;

  FamilyLoginRequest({
    required this.phone,
    required this.password,
  });

  factory FamilyLoginRequest.fromJson(Map<String, dynamic> json) => _$FamilyLoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyLoginRequestToJson(this);
}

@JsonSerializable()
class ElderlyLoginRequest {
  final String qrCode;

  ElderlyLoginRequest({
    required this.qrCode,
  });

  factory ElderlyLoginRequest.fromJson(Map<String, dynamic> json) => _$ElderlyLoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ElderlyLoginRequestToJson(this);
}

@JsonSerializable()
class FamilyRegisterRequest {
  final String fullName;
  final String email;
  final String phone;
  final String password;

  FamilyRegisterRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  factory FamilyRegisterRequest.fromJson(Map<String, dynamic> json) => _$FamilyRegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyRegisterRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final User user;
  final String token;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.token,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class QRCodeResponse {
  final String qrCode;
  final DateTime expiresAt;
  final String elderlyId;

  QRCodeResponse({
    required this.qrCode,
    required this.expiresAt,
    required this.elderlyId,
  });

  factory QRCodeResponse.fromJson(Map<String, dynamic> json) => _$QRCodeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QRCodeResponseToJson(this);
} 