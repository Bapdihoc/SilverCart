import 'package:json_annotation/json_annotation.dart';

part 'order_statistic_response.g.dart';

@JsonSerializable()
class OrderStatisticResponse {
  final String message;
  final OrderStatisticData data;

  const OrderStatisticResponse({
    required this.message,
    required this.data,
  });

  factory OrderStatisticResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderStatisticResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatisticResponseToJson(this);
}

@JsonSerializable()
class OrderStatisticData {
  final int totalCount;
  final int totalOrderToPending;
  final int totalOrderComplete;

  const OrderStatisticData({
    required this.totalCount,
    required this.totalOrderToPending,
    required this.totalOrderComplete,
  });

  factory OrderStatisticData.fromJson(Map<String, dynamic> json) =>
      _$OrderStatisticDataFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatisticDataToJson(this);
}
