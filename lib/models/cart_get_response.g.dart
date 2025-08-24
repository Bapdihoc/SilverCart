// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_get_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartGetResponse _$CartGetResponseFromJson(Map<String, dynamic> json) =>
    CartGetResponse(
      message: json['message'] as String,
      data: CartGetData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CartGetResponseToJson(CartGetResponse instance) =>
    <String, dynamic>{'message': instance.message, 'data': instance.data};

CartGetData _$CartGetDataFromJson(Map<String, dynamic> json) => CartGetData(
  cartId: json['cartId'] as String,
  customerId: json['customerId'] as String,
  customerName: json['customerName'] as String,
  elderId: json['elderId'] as String?,
  elderName: json['elderName'] as String?,
  status: json['status'] as String,
  items:
      (json['items'] as List<dynamic>)
          .map((e) => CartGetItem.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CartGetDataToJson(CartGetData instance) =>
    <String, dynamic>{
      'cartId': instance.cartId,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'elderId': instance.elderId,
      'elderName': instance.elderName,
      'status': instance.status,
      'items': instance.items,
    };

CartGetItem _$CartGetItemFromJson(Map<String, dynamic> json) => CartGetItem(
  productVariantId: json['productVariantId'] as String,
  productName: json['productName'] as String,
  quantity: (json['quantity'] as num).toInt(),
  productPrice: (json['productPrice'] as num).toDouble(),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$CartGetItemToJson(CartGetItem instance) =>
    <String, dynamic>{
      'productVariantId': instance.productVariantId,
      'productName': instance.productName,
      'quantity': instance.quantity,
      'productPrice': instance.productPrice,
      'imageUrl': instance.imageUrl,
    };
