// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_replace_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartReplaceRequest _$CartReplaceRequestFromJson(Map<String, dynamic> json) =>
    CartReplaceRequest(
      customerId: json['customerId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CartReplaceRequestToJson(CartReplaceRequest instance) =>
    <String, dynamic>{
      'customerId': instance.customerId,
      'items': instance.items,
    };

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
      productVariantId: json['productVariantId'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
      'productVariantId': instance.productVariantId,
      'quantity': instance.quantity,
    };
