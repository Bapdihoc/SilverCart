import 'package:json_annotation/json_annotation.dart';

part 'elder_budget_statistic_response.g.dart';

@JsonSerializable()
class ElderBudgetStatisticResponse {
  final String message;
  final List<ElderBudgetData> data;

  ElderBudgetStatisticResponse({
    required this.message,
    required this.data,
  });

  factory ElderBudgetStatisticResponse.fromJson(Map<String, dynamic> json) =>
      _$ElderBudgetStatisticResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ElderBudgetStatisticResponseToJson(this);
}

@JsonSerializable()
class ElderBudgetData {
  final String? elderId;
  final String? elderName;
  final double totalSpent;
  final double? limitSpent;
  final int orderCount;

  ElderBudgetData({
    this.elderId,
    this.elderName,
    required this.totalSpent,
    this.limitSpent,
    required this.orderCount,
  });

  factory ElderBudgetData.fromJson(Map<String, dynamic> json) =>
      _$ElderBudgetDataFromJson(json);

  Map<String, dynamic> toJson() => _$ElderBudgetDataToJson(this);

  // Helper getters
  bool get isSelf => elderId == null && elderName == null;
  
  String get displayName => isSelf ? 'Bản thân' : (elderName ?? 'Không xác định');
  
  double get budgetUsedPercent {
    if (limitSpent == null || limitSpent == 0) return 0;
    return (totalSpent / limitSpent!) * 100;
  }
  
  bool get isOverBudget {
    if (limitSpent == null) return false;
    return totalSpent > limitSpent!;
  }
  
  double get remainingBudget {
    if (limitSpent == null) return 0;
    return limitSpent! - totalSpent;
  }
}
