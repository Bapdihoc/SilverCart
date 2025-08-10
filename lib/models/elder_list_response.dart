import 'package:json_annotation/json_annotation.dart';

part 'elder_list_response.g.dart';

@JsonSerializable()
class ElderListResponse {
  final String message;
  final List<ElderData> data;

  ElderListResponse({
    required this.message,
    required this.data,
  });

  factory ElderListResponse.fromJson(Map<String, dynamic> json) => _$ElderListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ElderListResponseToJson(this);
}

@JsonSerializable()
class ElderData {
  final String id;
  final String fullName;
  final String userName;
  final String? description;
  final DateTime birthDate;
  final double spendLimit;
  final String emergencyPhoneNumber;
  final String relationShip;
  final bool isDelete;
  final String? avatar;
  final int gender;
  final List<ElderAddressData> addresses;
  final List<String> categories;

  ElderData({
    required this.id,
    required this.fullName,
    required this.userName,
    this.description,
    required this.birthDate,
    required this.spendLimit,
    required this.emergencyPhoneNumber,
    required this.relationShip,
    required this.isDelete,
    this.avatar,
    required this.gender,
    required this.addresses,
    required this.categories,
  });

  factory ElderData.fromJson(Map<String, dynamic> json) => _$ElderDataFromJson(json);
  Map<String, dynamic> toJson() => _$ElderDataToJson(this);
}

@JsonSerializable()
class ElderAddressData {
  final String id;
  final String streetAddress;
  final String wardCode;
  final String wardName;
  final int districtID;
  final String districtName;
  final int provinceID;
  final String provinceName;
  final String phoneNumber;

  ElderAddressData({
    required this.id,
    required this.streetAddress,
    required this.wardCode,
    required this.wardName,
    required this.districtID,
    required this.districtName,
    required this.provinceID,
    required this.provinceName,
    required this.phoneNumber,
  });

  factory ElderAddressData.fromJson(Map<String, dynamic> json) => _$ElderAddressDataFromJson(json);
  Map<String, dynamic> toJson() => _$ElderAddressDataToJson(this);
}
