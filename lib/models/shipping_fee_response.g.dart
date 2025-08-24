// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_fee_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShippingFeeResponse _$ShippingFeeResponseFromJson(Map<String, dynamic> json) =>
    ShippingFeeResponse(
      message: json['message'] as String,
      data: ShippingFeeData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ShippingFeeResponseToJson(
  ShippingFeeResponse instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};

ShippingFeeData _$ShippingFeeDataFromJson(Map<String, dynamic> json) =>
    ShippingFeeData(fee: (json['fee'] as num).toDouble());

Map<String, dynamic> _$ShippingFeeDataToJson(ShippingFeeData instance) =>
    <String, dynamic>{'fee': instance.fee};
