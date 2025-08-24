// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromotionResponse _$PromotionResponseFromJson(Map<String, dynamic> json) =>
    PromotionResponse(
      message: json['message'] as String,
      data:
          (json['data'] as List<dynamic>)
              .map((e) => PromotionData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$PromotionResponseToJson(PromotionResponse instance) =>
    <String, dynamic>{'message': instance.message, 'data': instance.data};

PromotionData _$PromotionDataFromJson(Map<String, dynamic> json) =>
    PromotionData(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      discountPercent: (json['discountPercent'] as num).toInt(),
      requiredPoints: (json['requiredPoints'] as num).toInt(),
      startAt: json['startAt'] as String?,
      endAt: json['endAt'] as String?,
      isActive: json['isActive'] as bool,
      creationDate: json['creationDate'] as String,
    );

Map<String, dynamic> _$PromotionDataToJson(PromotionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'discountPercent': instance.discountPercent,
      'requiredPoints': instance.requiredPoints,
      'startAt': instance.startAt,
      'endAt': instance.endAt,
      'isActive': instance.isActive,
      'creationDate': instance.creationDate,
    };
