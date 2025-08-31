// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elder_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElderOrderResponse _$ElderOrderResponseFromJson(Map<String, dynamic> json) =>
    ElderOrderResponse(
      message: json['message'] as String,
      data:
          (json['data'] as List<dynamic>)
              .map((e) => ElderOrderData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ElderOrderResponseToJson(ElderOrderResponse instance) =>
    <String, dynamic>{'message': instance.message, 'data': instance.data};

ElderOrderData _$ElderOrderDataFromJson(Map<String, dynamic> json) =>
    ElderOrderData(
      id: json['id'] as String,
      note: json['note'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      orderStatus: json['orderStatus'] as String,
      phoneNumber: json['phoneNumber'] as String,
      streetAddress: json['streetAddress'] as String,
      wardName: json['wardName'] as String,
      districtName: json['districtName'] as String,
      shippingCode: json['shippingCode'] as String?,
      provinceName: json['provinceName'] as String,
      shippingFee: (json['shippingFee'] as num?)?.toDouble(),
      customerName: json['customerName'] as String?,
      elderName: json['elderName'] as String?,
      creationDate: DateTime.parse(json['creationDate'] as String),
      expectedDeliveryTime:
          json['expectedDeliveryTime'] == null
              ? null
              : DateTime.parse(json['expectedDeliveryTime'] as String),
      orderDetails:
          (json['orderDetails'] as List<dynamic>)
              .map((e) => ElderOrderDetail.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ElderOrderDataToJson(ElderOrderData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'note': instance.note,
      'totalPrice': instance.totalPrice,
      'discount': instance.discount,
      'orderStatus': instance.orderStatus,
      'phoneNumber': instance.phoneNumber,
      'streetAddress': instance.streetAddress,
      'wardName': instance.wardName,
      'districtName': instance.districtName,
      'shippingCode': instance.shippingCode,
      'provinceName': instance.provinceName,
      'shippingFee': instance.shippingFee,
      'customerName': instance.customerName,
      'elderName': instance.elderName,
      'creationDate': instance.creationDate.toIso8601String(),
      'expectedDeliveryTime': instance.expectedDeliveryTime?.toIso8601String(),
      'orderDetails': instance.orderDetails,
    };

ElderOrderDetail _$ElderOrderDetailFromJson(Map<String, dynamic> json) =>
    ElderOrderDetail(
      id: json['id'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      discount: (json['discount'] as num).toDouble(),
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ElderOrderDetailToJson(ElderOrderDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productName': instance.productName,
      'price': instance.price,
      'quantity': instance.quantity,
      'discount': instance.discount,
      'images': instance.images,
    };
