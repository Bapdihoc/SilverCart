import 'package:json_annotation/json_annotation.dart';

part 'create_order_request.g.dart';

@JsonSerializable()
class CreateOrderRequest {
  final String cartId;
  final String note;
  final String addressId;
  final String? userPromotionId;

  CreateOrderRequest({
    required this.cartId,
    required this.note,
    required this.addressId,
    this.userPromotionId,
  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}
