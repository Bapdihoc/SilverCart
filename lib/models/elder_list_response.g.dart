// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elder_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElderListResponse _$ElderListResponseFromJson(Map<String, dynamic> json) =>
    ElderListResponse(
      message: json['message'] as String,
      data:
          (json['data'] as List<dynamic>)
              .map((e) => ElderData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ElderListResponseToJson(ElderListResponse instance) =>
    <String, dynamic>{'message': instance.message, 'data': instance.data};

ElderData _$ElderDataFromJson(Map<String, dynamic> json) => ElderData(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  userName: json['userName'] as String,
  description: json['description'] as String?,
  birthDate: DateTime.parse(json['birthDate'] as String),
  spendLimit: (json['spendLimit'] as num).toDouble(),
  emergencyPhoneNumber: json['emergencyPhoneNumber'] as String,
  relationShip: json['relationShip'] as String,
  isDelete: json['isDelete'] as bool,
  avatar: json['avatar'] as String?,
  gender: (json['gender'] as num).toInt(),
  addresses:
      (json['addresses'] as List<dynamic>)
          .map((e) => ElderAddressData.fromJson(e as Map<String, dynamic>))
          .toList(),
  categories:
      (json['categories'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ElderDataToJson(ElderData instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'userName': instance.userName,
  'description': instance.description,
  'birthDate': instance.birthDate.toIso8601String(),
  'spendLimit': instance.spendLimit,
  'emergencyPhoneNumber': instance.emergencyPhoneNumber,
  'relationShip': instance.relationShip,
  'isDelete': instance.isDelete,
  'avatar': instance.avatar,
  'gender': instance.gender,
  'addresses': instance.addresses,
  'categories': instance.categories,
};

ElderAddressData _$ElderAddressDataFromJson(Map<String, dynamic> json) =>
    ElderAddressData(
      id: json['id'] as String,
      streetAddress: json['streetAddress'] as String,
      wardCode: json['wardCode'] as String,
      wardName: json['wardName'] as String,
      districtID: (json['districtID'] as num).toInt(),
      districtName: json['districtName'] as String,
      provinceID: (json['provinceID'] as num).toInt(),
      provinceName: json['provinceName'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );

Map<String, dynamic> _$ElderAddressDataToJson(ElderAddressData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'streetAddress': instance.streetAddress,
      'wardCode': instance.wardCode,
      'wardName': instance.wardName,
      'districtID': instance.districtID,
      'districtName': instance.districtName,
      'provinceID': instance.provinceID,
      'provinceName': instance.provinceName,
      'phoneNumber': instance.phoneNumber,
    };
