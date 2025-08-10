import 'package:json_annotation/json_annotation.dart';

part 'user_me_response.g.dart';

@JsonSerializable()
class UserMeResponse {
  final String userId;
  final String userName;
  final String role;

  UserMeResponse({
    required this.userId,
    required this.userName,
    required this.role,
  });

  factory UserMeResponse.fromJson(Map<String, dynamic> json) => _$UserMeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserMeResponseToJson(this);
}
