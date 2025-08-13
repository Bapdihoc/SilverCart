import 'package:json_annotation/json_annotation.dart';

part 'change_cart_status_response.g.dart';

@JsonSerializable()
class ChangeCartStatusResponse {
  final String message;
  final dynamic data;

  ChangeCartStatusResponse({
    required this.message,
    this.data,
  });

  factory ChangeCartStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$ChangeCartStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeCartStatusResponseToJson(this);
}
