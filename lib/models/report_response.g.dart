// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportResponse _$ReportResponseFromJson(Map<String, dynamic> json) =>
    ReportResponse(
      message: json['message'] as String,
      data:
          (json['data'] as List<dynamic>)
              .map((e) => ReportData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ReportResponseToJson(ReportResponse instance) =>
    <String, dynamic>{'message': instance.message, 'data': instance.data};

ReportData _$ReportDataFromJson(Map<String, dynamic> json) => ReportData(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  userId: json['userId'] as String,
  consultantId: json['consultantId'] as String,
);

Map<String, dynamic> _$ReportDataToJson(ReportData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'userId': instance.userId,
      'consultantId': instance.consultantId,
    };
