import 'package:json_annotation/json_annotation.dart';

part 'promotion_response.g.dart';

@JsonSerializable()
class PromotionResponse {
  final String message;
  final List<PromotionData> data;

  PromotionResponse({
    required this.message,
    required this.data,
  });

  factory PromotionResponse.fromJson(Map<String, dynamic> json) =>
      _$PromotionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionResponseToJson(this);
}

@JsonSerializable()
class PromotionData {
  final String id;
  final String title;
  final String description;
  final int discountPercent;
  final int requiredPoints;
  final String? startAt;
  final String? endAt;
  final bool isActive;
  final String creationDate;

  PromotionData({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercent,
    required this.requiredPoints,
    this.startAt,
    this.endAt,
    required this.isActive,
    required this.creationDate,
  });

  factory PromotionData.fromJson(Map<String, dynamic> json) =>
      _$PromotionDataFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionDataToJson(this);

  // Helper getter to check if promotion is valid and active
  bool get isValidAndActive {
    if (!isActive) return false;
    if (startAt == null || endAt == null) return false;
    
    final now = DateTime.now();
    final start = DateTime.parse(startAt!);
    final end = DateTime.parse(endAt!);
    
    return now.isAfter(start) && now.isBefore(end);
  }

  // Helper getter to get formatted dates
  String get formattedPeriod {
    if (startAt == null || endAt == null) return 'Không xác định';
    
    final start = DateTime.parse(startAt!);
    final end = DateTime.parse(endAt!);
    
    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }
}
