// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletResponse _$WalletResponseFromJson(Map<String, dynamic> json) =>
    WalletResponse(
      message: json['message'] as String,
      data: WalletData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WalletResponseToJson(WalletResponse instance) =>
    <String, dynamic>{'message': instance.message, 'data': instance.data};

WalletData _$WalletDataFromJson(Map<String, dynamic> json) =>
    WalletData(amount: (json['amount'] as num).toDouble());

Map<String, dynamic> _$WalletDataToJson(WalletData instance) =>
    <String, dynamic>{'amount': instance.amount};
