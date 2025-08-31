// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_elder_address_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateElderAddressRequest _$UpdateElderAddressRequestFromJson(
  Map<String, dynamic> json,
) => UpdateElderAddressRequest(
  streetAddress: json['streetAddress'] as String,
  wardCode: json['wardCode'] as String,
  wardName: json['wardName'] as String,
  districtID: (json['districtID'] as num).toInt(),
  districtName: json['districtName'] as String,
  provinceID: (json['provinceID'] as num).toInt(),
  provinceName: json['provinceName'] as String,
  phoneNumber: json['phoneNumber'] as String,
);

Map<String, dynamic> _$UpdateElderAddressRequestToJson(
  UpdateElderAddressRequest instance,
) => <String, dynamic>{
  'streetAddress': instance.streetAddress,
  'wardCode': instance.wardCode,
  'wardName': instance.wardName,
  'districtID': instance.districtID,
  'districtName': instance.districtName,
  'provinceID': instance.provinceID,
  'provinceName': instance.provinceName,
  'phoneNumber': instance.phoneNumber,
};
