import 'package:json_annotation/json_annotation.dart';

part 'elderly_model.g.dart';

@JsonSerializable()
class Elderly {
  final String id;
  final String fullName;
  final String nickname;
  final DateTime dateOfBirth;
  final String relationship; // 'mother', 'father', 'grandmother', etc.
  final String phone;
  final String? avatar;
  final String? medicalNotes;
  final List<String>? dietaryRestrictions;
  final String? emergencyContact;
  final double monthlyBudgetLimit;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String managedBy; // Guardian ID
  final String? currentQRCode;
  final DateTime? qrCodeExpiresAt;
  final DateTime? lastLoginAt;
  final int totalOrders;
  final double totalSpent;
  final List<Address>? addresses;

  Elderly({
    required this.id,
    required this.fullName,
    required this.nickname,
    required this.dateOfBirth,
    required this.relationship,
    required this.phone,
    this.avatar,
    this.medicalNotes,
    this.dietaryRestrictions,
    this.emergencyContact,
    required this.monthlyBudgetLimit,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.managedBy,
    this.currentQRCode,
    this.qrCodeExpiresAt,
    this.lastLoginAt,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.addresses,
  });

  factory Elderly.fromJson(Map<String, dynamic> json) => _$ElderlyFromJson(json);
  Map<String, dynamic> toJson() => _$ElderlyToJson(this);

  Elderly copyWith({
    String? id,
    String? fullName,
    String? nickname,
    DateTime? dateOfBirth,
    String? relationship,
    String? phone,
    String? avatar,
    String? medicalNotes,
    List<String>? dietaryRestrictions,
    String? emergencyContact,
    double? monthlyBudgetLimit,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? managedBy,
    String? currentQRCode,
    DateTime? qrCodeExpiresAt,
    DateTime? lastLoginAt,
    int? totalOrders,
    double? totalSpent,
    List<Address>? addresses,
  }) {
    return Elderly(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      monthlyBudgetLimit: monthlyBudgetLimit ?? this.monthlyBudgetLimit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      managedBy: managedBy ?? this.managedBy,
      currentQRCode: currentQRCode ?? this.currentQRCode,
      qrCodeExpiresAt: qrCodeExpiresAt ?? this.qrCodeExpiresAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      addresses: addresses ?? this.addresses,
    );
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  bool get hasValidQRCode {
    return currentQRCode != null && 
           qrCodeExpiresAt != null && 
           qrCodeExpiresAt!.isAfter(DateTime.now());
  }

  String get statusText {
    if (!isActive) return 'Không hoạt động';
    if (lastLoginAt == null) return 'Chưa đăng nhập';
    
    final now = DateTime.now();
    final diff = now.difference(lastLoginAt!);
    
    if (diff.inDays > 7) return 'Không hoạt động';
    if (diff.inDays > 1) return 'Đăng nhập ${diff.inDays} ngày trước';
    if (diff.inHours > 1) return 'Đăng nhập ${diff.inHours} giờ trước';
    return 'Đang hoạt động';
  }

  String get budgetUsageText {
    final usage = (totalSpent / monthlyBudgetLimit * 100);
    return '${usage.toStringAsFixed(1)}% budget đã sử dụng';
  }
}

@JsonSerializable()
class Address {
  final String id;
  final String fullAddress;
  final String recipientName;
  final String recipientPhone;
  final String addressType; // 'home', 'work', 'other'
  final bool isDefault;
  final String? specialNotes;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.fullAddress,
    required this.recipientName,
    required this.recipientPhone,
    required this.addressType,
    required this.isDefault,
    this.specialNotes,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  Address copyWith({
    String? id,
    String? fullAddress,
    String? recipientName,
    String? recipientPhone,
    String? addressType,
    bool? isDefault,
    String? specialNotes,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      fullAddress: fullAddress ?? this.fullAddress,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      addressType: addressType ?? this.addressType,
      isDefault: isDefault ?? this.isDefault,
      specialNotes: specialNotes ?? this.specialNotes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class CreateElderlyRequest {
  final String fullName;
  final String nickname;
  final DateTime dateOfBirth;
  final String relationship;
  final String phone;
  final String? medicalNotes;
  final List<String>? dietaryRestrictions;
  final String? emergencyContact;
  final double monthlyBudgetLimit;
  final Address primaryAddress;

  CreateElderlyRequest({
    required this.fullName,
    required this.nickname,
    required this.dateOfBirth,
    required this.relationship,
    required this.phone,
    this.medicalNotes,
    this.dietaryRestrictions,
    this.emergencyContact,
    required this.monthlyBudgetLimit,
    required this.primaryAddress,
  });

  factory CreateElderlyRequest.fromJson(Map<String, dynamic> json) => _$CreateElderlyRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateElderlyRequestToJson(this);
}

@JsonSerializable()
class QRCodeData {
  final String elderlyId;
  final String code;
  final DateTime expiresAt;
  final DateTime generatedAt;
  final String generatedBy; // Guardian ID

  QRCodeData({
    required this.elderlyId,
    required this.code,
    required this.expiresAt,
    required this.generatedAt,
    required this.generatedBy,
  });

  factory QRCodeData.fromJson(Map<String, dynamic> json) => _$QRCodeDataFromJson(json);
  Map<String, dynamic> toJson() => _$QRCodeDataToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  String get timeRemaining {
    if (isExpired) return 'Đã hết hạn';
    
    final diff = expiresAt.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays} ngày';
    if (diff.inHours > 0) return '${diff.inHours} giờ';
    return '${diff.inMinutes} phút';
  }
} 