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
  final int orderStatus;
  final String elderName;
  final List<UserOrderDetail> orderDetails;

  UserOrderData({
    required this.id,
    required this.totalPrice,
    required this.note,
    required this.orderStatus,
    required this.elderName,
    required this.orderDetails,
  });

  factory UserOrderData.fromJson(Map<String, dynamic> json) =>
      _$UserOrderDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserOrderDataToJson(this);

  // Helper method to get order status text
  String get orderStatusText {
    switch (orderStatus) {
      case 0:
        return 'Đã tạo';
      case 1:
        return 'Đã thanh toán';
      case 2:
        return 'Đang giao';
      case 3:
        return 'Hoàn thành';
      case 4:
        return 'Thất bại';
      default:
        return 'Không xác định';
    }
  }

  // Helper method to get order status color
  String get orderStatusColor {
    switch (orderStatus) {
      case 0:
        return 'blue'; // Created
      case 1:
        return 'orange'; // Paid
      case 2:
        return 'purple'; // Shipping
      case 3:
        return 'green'; // Completed
      case 4:
        return 'red'; // Failed
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

  UserOrderDetail({
    required this.productName,
    required this.price,
    required this.quantity,
  });

  factory UserOrderDetail.fromJson(Map<String, dynamic> json) =>
      _$UserOrderDetailFromJson(json);

  Map<String, dynamic> toJson() => _$UserOrderDetailToJson(this);
}
