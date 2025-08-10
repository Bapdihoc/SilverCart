import 'package:json_annotation/json_annotation.dart';

part 'qr_generate_response.g.dart';

@JsonSerializable()
class QrGenerateResponse {
  final String message;
  final QrGenerateData data;

  QrGenerateResponse({
    required this.message,
    required this.data,
  });

  factory QrGenerateResponse.fromJson(Map<String, dynamic> json) => _$QrGenerateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QrGenerateResponseToJson(this);
}

@JsonSerializable()
class QrGenerateData {
  final String token;

  QrGenerateData({
    required this.token,
  });

  factory QrGenerateData.fromJson(Map<String, dynamic> json) => _$QrGenerateDataFromJson(json);
  Map<String, dynamic> toJson() => _$QrGenerateDataToJson(this);
}
