// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elderly_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Elderly _$ElderlyFromJson(Map<String, dynamic> json) => Elderly(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      nickname: json['nickname'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      relationship: json['relationship'] as String,
      phone: json['phone'] as String,
      avatar: json['avatar'] as String?,
      medicalNotes: json['medicalNotes'] as String?,
      dietaryRestrictions: (json['dietaryRestrictions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      emergencyContact: json['emergencyContact'] as String?,
      monthlyBudgetLimit: (json['monthlyBudgetLimit'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      managedBy: json['managedBy'] as String,
      currentQRCode: json['currentQRCode'] as String?,
      qrCodeExpiresAt: json['qrCodeExpiresAt'] == null
          ? null
          : DateTime.parse(json['qrCodeExpiresAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ElderlyToJson(Elderly instance) => <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'nickname': instance.nickname,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'relationship': instance.relationship,
      'phone': instance.phone,
      'avatar': instance.avatar,
      'medicalNotes': instance.medicalNotes,
      'dietaryRestrictions': instance.dietaryRestrictions,
      'emergencyContact': instance.emergencyContact,
      'monthlyBudgetLimit': instance.monthlyBudgetLimit,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'managedBy': instance.managedBy,
      'currentQRCode': instance.currentQRCode,
      'qrCodeExpiresAt': instance.qrCodeExpiresAt?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'totalOrders': instance.totalOrders,
      'totalSpent': instance.totalSpent,
      'addresses': instance.addresses,
    };

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      id: json['id'] as String,
      fullAddress: json['fullAddress'] as String,
      recipientName: json['recipientName'] as String,
      recipientPhone: json['recipientPhone'] as String,
      addressType: json['addressType'] as String,
      isDefault: json['isDefault'] as bool,
      specialNotes: json['specialNotes'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'id': instance.id,
      'fullAddress': instance.fullAddress,
      'recipientName': instance.recipientName,
      'recipientPhone': instance.recipientPhone,
      'addressType': instance.addressType,
      'isDefault': instance.isDefault,
      'specialNotes': instance.specialNotes,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CreateElderlyRequest _$CreateElderlyRequestFromJson(
        Map<String, dynamic> json) =>
    CreateElderlyRequest(
      fullName: json['fullName'] as String,
      nickname: json['nickname'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      relationship: json['relationship'] as String,
      phone: json['phone'] as String,
      medicalNotes: json['medicalNotes'] as String?,
      dietaryRestrictions: (json['dietaryRestrictions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      emergencyContact: json['emergencyContact'] as String?,
      monthlyBudgetLimit: (json['monthlyBudgetLimit'] as num).toDouble(),
      primaryAddress:
          Address.fromJson(json['primaryAddress'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateElderlyRequestToJson(
        CreateElderlyRequest instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'nickname': instance.nickname,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'relationship': instance.relationship,
      'phone': instance.phone,
      'medicalNotes': instance.medicalNotes,
      'dietaryRestrictions': instance.dietaryRestrictions,
      'emergencyContact': instance.emergencyContact,
      'monthlyBudgetLimit': instance.monthlyBudgetLimit,
      'primaryAddress': instance.primaryAddress,
    };

QRCodeData _$QRCodeDataFromJson(Map<String, dynamic> json) => QRCodeData(
      elderlyId: json['elderlyId'] as String,
      code: json['code'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      generatedBy: json['generatedBy'] as String,
    );

Map<String, dynamic> _$QRCodeDataToJson(QRCodeData instance) =>
    <String, dynamic>{
      'elderlyId': instance.elderlyId,
      'code': instance.code,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'generatedAt': instance.generatedAt.toIso8601String(),
      'generatedBy': instance.generatedBy,
    };
