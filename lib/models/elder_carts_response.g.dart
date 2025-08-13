// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elder_carts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElderCartsResponse _$ElderCartsResponseFromJson(Map<String, dynamic> json) =>
    ElderCartsResponse(
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => ElderCartData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ElderCartsResponseToJson(ElderCartsResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'data': instance.data,
    };

ElderCartData _$ElderCartDataFromJson(Map<String, dynamic> json) =>
    ElderCartData(
      cartId: json['cartId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      elderId: json['elderId'] as String,
      elderName: json['elderName'] as String,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ElderCartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ElderCartDataToJson(ElderCartData instance) =>
    <String, dynamic>{
      'cartId': instance.cartId,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'elderId': instance.elderId,
      'elderName': instance.elderName,
      'status': instance.status,
      'items': instance.items,
    };

ElderCartItem _$ElderCartItemFromJson(Map<String, dynamic> json) =>
    ElderCartItem(
      productVariantId: json['productVariantId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      productPrice: (json['productPrice'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      discount: (json['discount'] as num).toDouble(),
    );

Map<String, dynamic> _$ElderCartItemToJson(ElderCartItem instance) =>
    <String, dynamic>{
      'productVariantId': instance.productVariantId,
      'productName': instance.productName,
      'quantity': instance.quantity,
      'productPrice': instance.productPrice,
      'imageUrl': instance.imageUrl,
      'discount': instance.discount,
    };
