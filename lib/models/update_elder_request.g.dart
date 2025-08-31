// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_elder_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateElderRequest _$UpdateElderRequestFromJson(Map<String, dynamic> json) =>
    UpdateElderRequest(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      userName: json['userName'] as String,
      description: json['description'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      spendlimit: (json['spendlimit'] as num).toDouble(),
      avatar: json['avatar'] as String?,
      emergencyPhoneNumber: json['emergencyPhoneNumber'] as String,
      relationShip: json['relationShip'] as String,
      gender: (json['gender'] as num).toInt(),
    );

Map<String, dynamic> _$UpdateElderRequestToJson(UpdateElderRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'userName': instance.userName,
      'description': instance.description,
      'birthDate': instance.birthDate.toIso8601String(),
      'spendlimit': instance.spendlimit,
      'avatar': instance.avatar,
      'emergencyPhoneNumber': instance.emergencyPhoneNumber,
      'relationShip': instance.relationShip,
      'gender': instance.gender,
    };
