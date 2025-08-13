import 'package:json_annotation/json_annotation.dart';

part 'user_detail_response.g.dart';

@JsonSerializable()
class UserDetailResponse {
  final String message;
  final UserDetailData data;

  UserDetailResponse({
    required this.message,
    required this.data,
  });

  factory UserDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$UserDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserDetailResponseToJson(this);
}

@JsonSerializable()
class UserDetailData {
  final String id;
  final String fullName;
  final String userName;
  final String? email;
  final String? avatar;
  final int gender;
  final String? phoneNumber;
  final DateTime birthDate;
  final int age;
  final int rewardPoint;
  final String description;
  final String relationShip;
  final String guardianId;
  final String roleId;
  final String roleName;
  final List<UserDetailAddress> addresses;
  final List<UserCategoryValue> categoryValues;
  final String? emergencyPhoneNumber;

  UserDetailData({
    required this.id,
    required this.fullName,
    required this.userName,
    this.email,
    this.avatar,
    required this.gender,
    this.phoneNumber,
    required this.birthDate,
    required this.age,
    required this.rewardPoint,
    required this.description,
    required this.relationShip,
    required this.guardianId,
    required this.roleId,
    required this.roleName,
    required this.addresses,
    required this.categoryValues,
    this.emergencyPhoneNumber,
  });

  factory UserDetailData.fromJson(Map<String, dynamic> json) =>
      _$UserDetailDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDetailDataToJson(this);
}

@JsonSerializable()
class UserDetailAddress {
  final String id;
  final String streetAddress;
  final String wardCode;
  final String wardName;
  final int districtID;
  final String districtName;
  final int provinceID;
  final String provinceName;
  final String phoneNumber;

  UserDetailAddress({
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

  factory UserDetailAddress.fromJson(Map<String, dynamic> json) =>
      _$UserDetailAddressFromJson(json);

  Map<String, dynamic> toJson() => _$UserDetailAddressToJson(this);
}

@JsonSerializable()
class UserCategoryValue {
  final String id;
  final String code;
  final String description;
  final String label;
  final int type;
  final String? childrenId;
  final String? childrentLabel;

  UserCategoryValue({
    required this.id,
    required this.code,
    required this.description,
    required this.label,
    required this.type,
    this.childrenId,
    this.childrentLabel,
  });

  factory UserCategoryValue.fromJson(Map<String, dynamic> json) =>
      _$UserCategoryValueFromJson(json);

  Map<String, dynamic> toJson() => _$UserCategoryValueToJson(this);
}
