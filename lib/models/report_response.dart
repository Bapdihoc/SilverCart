import 'package:json_annotation/json_annotation.dart';

part 'report_response.g.dart';

@JsonSerializable()
class ReportResponse {
  final String message;
  final List<ReportData> data;

  const ReportResponse({
    required this.message,
    required this.data,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) =>
      _$ReportResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReportResponseToJson(this);
}

@JsonSerializable()
class ReportData {
  final String id;
  final String title;
  final String description;
  @JsonKey(name: 'userId')
  final String userId;
  @JsonKey(name: 'consultantId')
  final String consultantId;

  const ReportData({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.consultantId,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) =>
      _$ReportDataFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDataToJson(this);
}
