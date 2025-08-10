import 'package:json_annotation/json_annotation.dart';

part 'cart_replace_request.g.dart';

@JsonSerializable()
class CartReplaceRequest {
  final String customerId;
  final List<CartItem> items;

  CartReplaceRequest({
    required this.customerId,
    required this.items,
  });

  factory CartReplaceRequest.fromJson(Map<String, dynamic> json) => _$CartReplaceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CartReplaceRequestToJson(this);
}

@JsonSerializable()
class CartItem {
  final String productVariantId;
  final int quantity;

  CartItem({
    required this.productVariantId,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}
