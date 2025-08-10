// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_me_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserMeResponse _$UserMeResponseFromJson(Map<String, dynamic> json) =>
    UserMeResponse(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$UserMeResponseToJson(UserMeResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'role': instance.role,
    };
