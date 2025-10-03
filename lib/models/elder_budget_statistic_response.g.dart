// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elder_budget_statistic_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElderBudgetStatisticResponse _$ElderBudgetStatisticResponseFromJson(
  Map<String, dynamic> json,
) => ElderBudgetStatisticResponse(
  message: json['message'] as String,
  data:
      (json['data'] as List<dynamic>)
          .map((e) => ElderBudgetData.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ElderBudgetStatisticResponseToJson(
  ElderBudgetStatisticResponse instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};

ElderBudgetData _$ElderBudgetDataFromJson(Map<String, dynamic> json) =>
    ElderBudgetData(
      elderId: json['elderId'] as String?,
      elderName: json['elderName'] as String?,
      totalSpent: (json['totalSpent'] as num).toDouble(),
      limitSpent: (json['limitSpent'] as num?)?.toDouble(),
      orderCount: (json['orderCount'] as num).toInt(),
    );

Map<String, dynamic> _$ElderBudgetDataToJson(ElderBudgetData instance) =>
    <String, dynamic>{
      'elderId': instance.elderId,
      'elderName': instance.elderName,
      'totalSpent': instance.totalSpent,
      'limitSpent': instance.limitSpent,
      'orderCount': instance.orderCount,
    };
