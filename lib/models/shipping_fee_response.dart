import 'package:json_annotation/json_annotation.dart';

part 'shipping_fee_response.g.dart';

@JsonSerializable()
class ShippingFeeResponse {
  final String message;
  final ShippingFeeData data;

  const ShippingFeeResponse({
    required this.message,
    required this.data,
  });

  factory ShippingFeeResponse.fromJson(Map<String, dynamic> json) =>
      _$ShippingFeeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ShippingFeeResponseToJson(this);
}

@JsonSerializable()
class ShippingFeeData {
  final double fee;

  const ShippingFeeData({
    required this.fee,
  });

  factory ShippingFeeData.fromJson(Map<String, dynamic> json) =>
      _$ShippingFeeDataFromJson(json);

  Map<String, dynamic> toJson() => _$ShippingFeeDataToJson(this);
}
