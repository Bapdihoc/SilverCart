import 'package:json_annotation/json_annotation.dart';

part 'elder_carts_response.g.dart';

@JsonSerializable()
class ElderCartsResponse {
  final String message;
  final List<ElderCartData> data;

  ElderCartsResponse({
    required this.message,
    required this.data,
  });

  factory ElderCartsResponse.fromJson(Map<String, dynamic> json) =>
      _$ElderCartsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ElderCartsResponseToJson(this);
}

@JsonSerializable()
class ElderCartData {
  final String cartId;
  final String customerId;
  final String customerName;
  final String elderId;
  final String elderName;
  final String status;
  final List<ElderCartItem> items;

  ElderCartData({
    required this.cartId,
    required this.customerId,
    required this.customerName,
    required this.elderId,
    required this.elderName,
    required this.status,
    required this.items,
  });

  factory ElderCartData.fromJson(Map<String, dynamic> json) =>
      _$ElderCartDataFromJson(json);

  Map<String, dynamic> toJson() => _$ElderCartDataToJson(this);

  // Helper getters for UI
  String get statusText {
    switch (status.toLowerCase()) {
      case 'created':
        return 'Đã tạo';
      case 'pending':
        return 'Chờ duyệt';
      case 'approve':
        return 'Đã duyệt';
      case 'reject':
        return 'Từ chối';
      default:
        return 'Không xác định';
    }
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'created':
        return 'blue';
      case 'pending':
        return 'orange';
      case 'approve':
        return 'green';
      case 'reject':
        return 'red';
      default:
        return 'grey';
    }
  }

  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + (item.productPrice * item.quantity));
  }

  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

@JsonSerializable()
class ElderCartItem {
  final String productVariantId;
  final String productName;
  final int quantity;
  final double productPrice;
  final String? imageUrl;
  final double discount;

  ElderCartItem({
    required this.productVariantId,
    required this.productName,
    required this.quantity,
    required this.productPrice,
    this.imageUrl,
    required this.discount,
  });

  factory ElderCartItem.fromJson(Map<String, dynamic> json) =>
      _$ElderCartItemFromJson(json);

  Map<String, dynamic> toJson() => _$ElderCartItemToJson(this);
}
