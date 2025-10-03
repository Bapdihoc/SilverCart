import 'package:json_annotation/json_annotation.dart';

part 'withdrawal_request.g.dart';

@JsonSerializable()
class WithdrawalRequest {
  final String bankName;
  final String bankAccountNumber;
  final String accountHolder;
  final String note;
  final double amount;

  const WithdrawalRequest({
    required this.bankName,
    required this.bankAccountNumber,
    required this.accountHolder,
    required this.note,
    required this.amount,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawalRequestToJson(this);
}
