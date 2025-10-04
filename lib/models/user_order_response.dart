import 'package:json_annotation/json_annotation.dart';

part 'user_order_response.g.dart';

@JsonSerializable()
class UserOrderResponse {
  final String message;
  final List<UserOrderData> data;

  UserOrderResponse({
    required this.message,
    required this.data,
  });

  factory UserOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$UserOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserOrderResponseToJson(this);
}

@JsonSerializable()
class UserOrderData {
  final String id;
  final double totalPrice;
  final String note;
  final String orderStatus;
  final String? elderName;
  final List<UserOrderDetail> orderDetails;
  final String? streetAddress;
  final String? wardName;
  final String? districtName;
  final String? provinceName;
  final String? shippingCode;
  final double? shippingFee;
  final String? paymentMethod;
  final String? customerName;

  UserOrderData({
    required this.id,
    required this.totalPrice,
    required this.note,
    required this.orderStatus,
    required this.elderName,
    required this.orderDetails,
    this.streetAddress,
    this.wardName,
    this.districtName,
    this.provinceName,
    this.shippingCode,
    this.shippingFee,
    this.paymentMethod,
    this.customerName,
  });

  factory UserOrderData.fromJson(Map<String, dynamic> json) =>
      _$UserOrderDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserOrderDataToJson(this);

  // Helper method to get order status text
  String get orderStatusText {
    switch (orderStatus) {
      // Created,         // Đã tạo
      //   Paid,            // Đã thanh toán
      //   PendingChecked,  // Chờ kiểm tra
      //   PendingConfirm,  // Chờ xác nhận
      //   PendingPickup,   // Chờ lấy hàng
      //   PendingDelivery, // Chờ giao hàng
      //   Shipping,        // Đang giao
      //   Delivered,       // Đã giao
      //   Completed,       // Hoàn tất
      //   Canceled,        // Đã hủy
      //   Fail             // Thất bại
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

  // Helper method to get order status color
  String get orderStatusColor {
    switch (orderStatus) {
      case 'Created':
        return 'blue'; // Created
      case 'Paid':
        return 'orange'; // Paid
      case 'PendingChecked':
        return 'purple'; // Shipping
      case 'PendingConfirm':
        return 'green'; // Completed
      case 'PendingPickup':
        return 'red'; // PendingPickup
      case 'PendingDelivery':
        return 'red'; // PendingDelivery
      case 'Shipping':
        return 'red'; // Shipping
      case 'Delivered':
        return 'red'; // Delivered
      case 'Completed':
        return 'green'; // Completed
      case 'Canceled':
        return 'red'; // Canceled
      case 'Fail':
        return 'red'; // Fail
      default:
        return 'grey';
    }
  }
}

@JsonSerializable()
class UserOrderDetail {
  final String productName;
  final double price;
  final int quantity;
  final double? discount; // Discount percentage (0-100)

  UserOrderDetail({
    required this.productName,
    required this.price,
    required this.quantity,
    this.discount,
  });

  factory UserOrderDetail.fromJson(Map<String, dynamic> json) =>
      _$UserOrderDetailFromJson(json);

  Map<String, dynamic> toJson() => _$UserOrderDetailToJson(this);
}
