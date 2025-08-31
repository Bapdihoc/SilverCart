import 'package:json_annotation/json_annotation.dart';

part 'elder_order_response.g.dart';

@JsonSerializable()
class ElderOrderResponse {
  final String message;
  final List<ElderOrderData> data;

  ElderOrderResponse({
    required this.message,
    required this.data,
  });

  factory ElderOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$ElderOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ElderOrderResponseToJson(this);
}

@JsonSerializable()
class ElderOrderData {
  final String id;
  final String note;
  final double totalPrice;
  final double discount;
  final String orderStatus;
  final String phoneNumber;
  final String streetAddress;
  final String wardName;
  final String districtName;
  final String? shippingCode;
  final String provinceName;
  final double? shippingFee;
  final String? customerName;
  final String? elderName;
  final DateTime creationDate;
  final DateTime? expectedDeliveryTime;
  final List<ElderOrderDetail> orderDetails;

  ElderOrderData({
    required this.id,
    required this.note,
    required this.totalPrice,
    required this.discount,
    required this.orderStatus,
    required this.phoneNumber,
    required this.streetAddress,
    required this.wardName,
    required this.districtName,
     this.shippingCode,
    required this.provinceName,
     this.shippingFee,
    this.customerName,
    this.elderName,
    required this.creationDate,
     this.expectedDeliveryTime,
    required this.orderDetails,
  });

  factory ElderOrderData.fromJson(Map<String, dynamic> json) =>
      _$ElderOrderDataFromJson(json);

  Map<String, dynamic> toJson() => _$ElderOrderDataToJson(this);

  // Helper method to get order status text in Vietnamese
  String get orderStatusText {
    switch (orderStatus) {
      case 'Created':
        return 'Đã tạo';
      case 'Paid':
        return 'Đã thanh toán';
      case 'PendingChecked':
        return 'Chờ kiểm tra';
      case 'PendingConfirm':
        return 'Chờ xác nhận';
      case 'PendingPickup':
        return 'Chờ lấy hàng';
      case 'PendingDelivery':
        return 'Chờ giao hàng';
      case 'Shipping':
        return 'Đang giao';
      case 'Delivered':
        return 'Đã giao';
      case 'Completed':
        return 'Hoàn tất';
      case 'Canceled':
        return 'Đã hủy';
      case 'Fail':
        return 'Thất bại';
      default:
        return 'Không xác định';
    }
  }

  // Helper method to get formatted creation date
  String get formattedCreationDate {
    final now = DateTime.now();
    final difference = now.difference(creationDate);

    if (difference.inDays == 0) {
      return 'Hôm nay, ${creationDate.hour.toString().padLeft(2, '0')}:${creationDate.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hôm qua, ${creationDate.hour.toString().padLeft(2, '0')}:${creationDate.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${creationDate.day}/${creationDate.month}/${creationDate.year}';
    }
  }

  // Helper method to get formatted total price
  String get formattedTotalPrice {
    return '${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  // Helper method to get product names as list for display
  List<String> get productNames {
    return orderDetails.map((detail) => detail.productName).toList();
  }

  // Helper method to get full address
  String get fullAddress {
    final addressParts = <String>[];
    if (streetAddress.isNotEmpty) addressParts.add(streetAddress);
    if (wardName.isNotEmpty) addressParts.add(wardName);
    if (districtName.isNotEmpty) addressParts.add(districtName);
    if (provinceName.isNotEmpty) addressParts.add(provinceName);
    return addressParts.join(', ');
  }
}

@JsonSerializable()
class ElderOrderDetail {
  final String id;
  final String productName;
  final double price;
  final int quantity;
  final double discount;
  final List<String> images;

  ElderOrderDetail({
    required this.id,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.discount,
    required this.images,
  });

  factory ElderOrderDetail.fromJson(Map<String, dynamic> json) =>
      _$ElderOrderDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ElderOrderDetailToJson(this);

  // Helper method to get formatted price
  String get formattedPrice {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }
}
