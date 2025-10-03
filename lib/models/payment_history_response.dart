import 'package:json_annotation/json_annotation.dart';

part 'payment_history_response.g.dart';

@JsonSerializable()
class PaymentHistoryResponse {
  final String message;
  final PaymentHistoryData data;

  PaymentHistoryResponse({
    required this.message,
    required this.data,
  });

  factory PaymentHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentHistoryResponseToJson(this);
}

@JsonSerializable()
class PaymentHistoryData {
  final int totalItems;
  final List<PaymentHistoryItem> items;

  PaymentHistoryData({
    required this.totalItems,
    required this.items,
  });

  factory PaymentHistoryData.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryDataFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentHistoryDataToJson(this);
}

@JsonSerializable()
class PaymentHistoryItem {
  final String id;
  final double amount;
  final String userId;
  final String userName;
  final String? avatar;
  final String paymentMenthod; // Note: API has typo "Menthod" instead of "Method"
  final int paymentStatus;
  final DateTime creationDate;
  final String? orderId;

  PaymentHistoryItem({
    required this.id,
    required this.amount,
    required this.userId,
    required this.userName,
    this.avatar,
    required this.paymentMenthod,
    required this.paymentStatus,
    required this.creationDate,
    required this.orderId,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentHistoryItemToJson(this);

  // Helper getters
  String get statusText {
    switch (paymentStatus) {
      case 0:
        return 'Nạp tiền';
      case 1:
        return 'Thanh toán';
      case 2:
        return 'Hoàn tiền';
      case 3:
        return 'Rút tiền';
      default:
        return 'Không xác định';
    }
  }

  String get statusColor {
    switch (paymentStatus) {
      case 0:
        return 'orange'; // Pending
      case 1:
        return 'green'; // Success
      case 2:
        return 'red'; // Failed
      case 3:
        return 'grey'; // Cancelled
      default:
        return 'grey';
    }
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(creationDate);

    if (difference.inDays == 0) {
      return 'Hôm nay ${creationDate.hour.toString().padLeft(2, '0')}:${creationDate.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hôm qua ${creationDate.hour.toString().padLeft(2, '0')}:${creationDate.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${creationDate.day.toString().padLeft(2, '0')}/${creationDate.month.toString().padLeft(2, '0')}/${creationDate.year}';
    }
  }
}

@JsonSerializable()
class PaymentHistorySearchRequest {
  final DateTime startDate;
  final DateTime endDate;
  final String userId;

  PaymentHistorySearchRequest({
    required this.startDate,
    required this.endDate,
    required this.userId,
  });

  factory PaymentHistorySearchRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistorySearchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentHistorySearchRequestToJson(this);
}
