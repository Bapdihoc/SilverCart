// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_statistic_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderStatisticResponse _$OrderStatisticResponseFromJson(
  Map<String, dynamic> json,
) => OrderStatisticResponse(
  message: json['message'] as String,
  data: OrderStatisticData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderStatisticResponseToJson(
  OrderStatisticResponse instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};

OrderStatisticData _$OrderStatisticDataFromJson(Map<String, dynamic> json) =>
    OrderStatisticData(
      totalCount: (json['totalCount'] as num).toInt(),
      totalOrderToPending: (json['totalOrderToPending'] as num).toInt(),
      totalOrderComplete: (json['totalOrderComplete'] as num).toInt(),
    );

Map<String, dynamic> _$OrderStatisticDataToJson(OrderStatisticData instance) =>
    <String, dynamic>{
      'totalCount': instance.totalCount,
      'totalOrderToPending': instance.totalOrderToPending,
      'totalOrderComplete': instance.totalOrderComplete,
    };
