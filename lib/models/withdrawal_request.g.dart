// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawalRequest _$WithdrawalRequestFromJson(Map<String, dynamic> json) =>
    WithdrawalRequest(
      bankName: json['bankName'] as String,
      bankAccountNumber: json['bankAccountNumber'] as String,
      accountHolder: json['accountHolder'] as String,
      note: json['note'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$WithdrawalRequestToJson(WithdrawalRequest instance) =>
    <String, dynamic>{
      'bankName': instance.bankName,
      'bankAccountNumber': instance.bankAccountNumber,
      'accountHolder': instance.accountHolder,
      'note': instance.note,
      'amount': instance.amount,
    };
