import 'package:json_annotation/json_annotation.dart';

part 'wallet_response.g.dart';

@JsonSerializable()
class WalletResponse {
  final String message;
  final WalletData data;

  WalletResponse({
    required this.message,
    required this.data,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) =>
      _$WalletResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WalletResponseToJson(this);
}

@JsonSerializable()
class WalletData {
  final double amount;

  WalletData({
    required this.amount,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) =>
      _$WalletDataFromJson(json);

  Map<String, dynamic> toJson() => _$WalletDataToJson(this);
}
