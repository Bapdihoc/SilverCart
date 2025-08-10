import 'package:json_annotation/json_annotation.dart';

part 'cart_get_response.g.dart';

@JsonSerializable()
class CartGetResponse {
  final String message;
  final CartGetData data;

  CartGetResponse({
    required this.message,
    required this.data,
  });

  factory CartGetResponse.fromJson(Map<String, dynamic> json) => _$CartGetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CartGetResponseToJson(this);
}

@JsonSerializable()
class CartGetData {
  final String cartId;
  final String customerId;
  final String customerName;
  final String? elderId;
  final String? elderName;
  final String status;
  final List<CartGetItem> items;

  CartGetData({
    required this.cartId,
    required this.customerId,
    required this.customerName,
    required this.elderId,
    this.elderName,
    required this.status,
    required this.items,
  });

  factory CartGetData.fromJson(Map<String, dynamic> json) => _$CartGetDataFromJson(json);
  Map<String, dynamic> toJson() => _$CartGetDataToJson(this);
}

@JsonSerializable()
class CartGetItem {
  final String productVariantId;
  final String productName;
  final int quantity;
  final double productPrice;
  final String? imageUrl;

  CartGetItem({
    required this.productVariantId,
    required this.productName,
    required this.quantity,
    required this.productPrice,
    this.imageUrl,
  });

  factory CartGetItem.fromJson(Map<String, dynamic> json) => _$CartGetItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartGetItemToJson(this);
}
