// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserOrderResponse _$UserOrderResponseFromJson(Map<String, dynamic> json) =>
    UserOrderResponse(
      message: json['message'] as String,
      data:
          (json['data'] as List<dynamic>)
              .map((e) => UserOrderData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$UserOrderResponseToJson(UserOrderResponse instance) =>
    <String, dynamic>{'message': instance.message, 'data': instance.data};

UserOrderData _$UserOrderDataFromJson(Map<String, dynamic> json) =>
    UserOrderData(
      id: json['id'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      note: json['note'] as String,
      orderStatus: json['orderStatus'] as String,
      elderName: json['elderName'] as String?,
      orderDetails:
          (json['orderDetails'] as List<dynamic>)
              .map((e) => UserOrderDetail.fromJson(e as Map<String, dynamic>))
              .toList(),
      streetAddress: json['streetAddress'] as String?,
      wardName: json['wardName'] as String?,
      districtName: json['districtName'] as String?,
      provinceName: json['provinceName'] as String?,
      shippingCode: json['shippingCode'] as String?,
      shippingFee: (json['shippingFee'] as num?)?.toDouble(),
      paymentMethod: json['paymentMethod'] as String?,
    );

Map<String, dynamic> _$UserOrderDataToJson(UserOrderData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'totalPrice': instance.totalPrice,
      'note': instance.note,
      'orderStatus': instance.orderStatus,
      'elderName': instance.elderName,
      'orderDetails': instance.orderDetails,
      'streetAddress': instance.streetAddress,
      'wardName': instance.wardName,
      'districtName': instance.districtName,
      'provinceName': instance.provinceName,
      'shippingCode': instance.shippingCode,
      'shippingFee': instance.shippingFee,
      'paymentMethod': instance.paymentMethod,
    };

UserOrderDetail _$UserOrderDetailFromJson(Map<String, dynamic> json) =>
    UserOrderDetail(
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      discount: (json['discount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$UserOrderDetailToJson(UserOrderDetail instance) =>
    <String, dynamic>{
      'productName': instance.productName,
      'price': instance.price,
      'quantity': instance.quantity,
      'discount': instance.discount,
    };
