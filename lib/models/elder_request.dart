import 'dart:convert';

class ElderRequest {
  final String fullName;
  final String userName;
  final String description;
  final DateTime birthDate;
  final double spendlimit;
  final String? avatar;
  final String emergencyPhoneNumber;
  final String relationShip;
  final int gender;
  final List<String> categoryValueIds;
  final List<ElderAddress> addresses;

  ElderRequest({
    required this.fullName,
    required this.userName,
    required this.description,
    required this.birthDate,
    required this.spendlimit,
    this.avatar,
    required this.emergencyPhoneNumber,
    required this.relationShip,
    required this.gender,
    required this.categoryValueIds,
    required this.addresses,
  });

  factory ElderRequest.fromJson(Map<String, dynamic> json) {
    return ElderRequest(
      fullName: json['fullName'] ?? '',
      userName: json['userName'] ?? '',
      description: json['description'] ?? '',
      birthDate: DateTime.parse(json['birthDate']),
      spendlimit: (json['spendlimit'] ?? 0).toDouble(),
      avatar: json['avatar'],
      emergencyPhoneNumber: json['emergencyPhoneNumber'] ?? '',
      relationShip: json['relationShip'] ?? '',
      gender: json['gender'] ?? 0,
      categoryValueIds: List<String>.from(json['categoryValueIds'] ?? []),
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((item) => ElderAddress.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'userName': userName,
      'description': description,
      'birthDate': birthDate.toIso8601String(),
      'spendlimit': spendlimit,
      'avatar': avatar,
      'emergencyPhoneNumber': emergencyPhoneNumber,
      'relationShip': relationShip,
      'gender': gender,
      'categoryValueIds': categoryValueIds,
      'addresses': addresses.map((item) => item.toJson()).toList(),
    };
  }
}

class ElderAddress {
  final String streetAddress;
  final int wardCode;
  final String wardName;
  final int districtID;
  final String districtName;
  final int provinceID;
  final String provinceName;
  final String phoneNumber;

  ElderAddress({
    required this.streetAddress,
    required this.wardCode,
    required this.wardName,
    required this.districtID,
    required this.districtName,
    required this.provinceID,
    required this.provinceName,
    required this.phoneNumber,
  });

  factory ElderAddress.fromJson(Map<String, dynamic> json) {
    return ElderAddress(
      streetAddress: json['streetAddress'] ?? '',
      wardCode: json['wardCode'] ?? 0,
      wardName: json['wardName'] ?? '',
      districtID: json['districtID'] ?? 0,
      districtName: json['districtName'] ?? '',
      provinceID: json['provinceID'] ?? 0,
      provinceName: json['provinceName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streetAddress': streetAddress,
      'wardCode': wardCode,
      'wardName': wardName,
      'districtID': districtID,
      'districtName': districtName,
      'provinceID': provinceID,
      'provinceName': provinceName,
      'phoneNumber': phoneNumber,
    };
  }
}
