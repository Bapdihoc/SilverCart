// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_generate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QrGenerateResponse _$QrGenerateResponseFromJson(Map<String, dynamic> json) =>
    QrGenerateResponse(
      message: json['message'] as String,
      data: QrGenerateData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QrGenerateResponseToJson(QrGenerateResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'data': instance.data,
    };

QrGenerateData _$QrGenerateDataFromJson(Map<String, dynamic> json) =>
    QrGenerateData(
      token: json['token'] as String,
    );

Map<String, dynamic> _$QrGenerateDataToJson(QrGenerateData instance) =>
    <String, dynamic>{
      'token': instance.token,
    };
