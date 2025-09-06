import 'package:json_annotation/json_annotation.dart';

part 'withdrawal_response.g.dart';

@JsonSerializable()
class WithdrawalResponse {
  final dynamic data;
  final String message;

  const WithdrawalResponse({
    required this.data,
    required this.message,
  });

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawalResponseToJson(this);
}
