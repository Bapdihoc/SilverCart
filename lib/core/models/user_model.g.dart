// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool,
      avatar: json['avatar'] as String?,
      familyMembers: (json['familyMembers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      managedBy: json['managedBy'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'role': instance.role,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
      'avatar': instance.avatar,
      'familyMembers': instance.familyMembers,
      'managedBy': instance.managedBy,
    };

FamilyLoginRequest _$FamilyLoginRequestFromJson(Map<String, dynamic> json) =>
    FamilyLoginRequest(
      phone: json['phone'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$FamilyLoginRequestToJson(FamilyLoginRequest instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'password': instance.password,
    };

ElderlyLoginRequest _$ElderlyLoginRequestFromJson(Map<String, dynamic> json) =>
    ElderlyLoginRequest(
      qrCode: json['qrCode'] as String,
    );

Map<String, dynamic> _$ElderlyLoginRequestToJson(
        ElderlyLoginRequest instance) =>
    <String, dynamic>{
      'qrCode': instance.qrCode,
    };

FamilyRegisterRequest _$FamilyRegisterRequestFromJson(
        Map<String, dynamic> json) =>
    FamilyRegisterRequest(
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$FamilyRegisterRequestToJson(
        FamilyRegisterRequest instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'password': instance.password,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'token': instance.token,
      'refreshToken': instance.refreshToken,
    };

QRCodeResponse _$QRCodeResponseFromJson(Map<String, dynamic> json) =>
    QRCodeResponse(
      qrCode: json['qrCode'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      elderlyId: json['elderlyId'] as String,
    );

Map<String, dynamic> _$QRCodeResponseToJson(QRCodeResponse instance) =>
    <String, dynamic>{
      'qrCode': instance.qrCode,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'elderlyId': instance.elderlyId,
    };
