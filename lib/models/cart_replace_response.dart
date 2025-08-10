import 'package:json_annotation/json_annotation.dart';

part 'cart_replace_response.g.dart';

@JsonSerializable()
class CartReplaceResponse {
  final String message;
  final dynamic data;

  CartReplaceResponse({
    required this.message,
    this.data,
  });

  factory CartReplaceResponse.fromJson(Map<String, dynamic> json) => _$CartReplaceResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CartReplaceResponseToJson(this);
}
