// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentHistoryResponse _$PaymentHistoryResponseFromJson(
  Map<String, dynamic> json,
) => PaymentHistoryResponse(
  message: json['message'] as String,
  data: PaymentHistoryData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PaymentHistoryResponseToJson(
  PaymentHistoryResponse instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};

PaymentHistoryData _$PaymentHistoryDataFromJson(Map<String, dynamic> json) =>
    PaymentHistoryData(
      totalItems: (json['totalItems'] as num).toInt(),
      items:
          (json['items'] as List<dynamic>)
              .map(
                (e) => PaymentHistoryItem.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$PaymentHistoryDataToJson(PaymentHistoryData instance) =>
    <String, dynamic>{
      'totalItems': instance.totalItems,
      'items': instance.items,
    };

PaymentHistoryItem _$PaymentHistoryItemFromJson(Map<String, dynamic> json) =>
    PaymentHistoryItem(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      avatar: json['avatar'] as String?,
      paymentMenthod: json['paymentMenthod'] as String,
      paymentStatus: (json['paymentStatus'] as num).toInt(),
      creationDate: DateTime.parse(json['creationDate'] as String),
      orderId: json['orderId'] as String?,
    );

Map<String, dynamic> _$PaymentHistoryItemToJson(PaymentHistoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'userId': instance.userId,
      'userName': instance.userName,
      'avatar': instance.avatar,
      'paymentMenthod': instance.paymentMenthod,
      'paymentStatus': instance.paymentStatus,
      'creationDate': instance.creationDate.toIso8601String(),
      'orderId': instance.orderId,
    };

PaymentHistorySearchRequest _$PaymentHistorySearchRequestFromJson(
  Map<String, dynamic> json,
) => PaymentHistorySearchRequest(
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  userId: json['userId'] as String,
);

Map<String, dynamic> _$PaymentHistorySearchRequestToJson(
  PaymentHistorySearchRequest instance,
) => <String, dynamic>{
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'userId': instance.userId,
};
