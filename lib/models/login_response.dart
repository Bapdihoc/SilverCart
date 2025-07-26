// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
    String userId;
    String role;
    String accessToken;
    String refreshToken;
    DateTime expiration;

    LoginResponse({
        required this.userId,
        required this.role,
        required this.accessToken,
        required this.refreshToken,
        required this.expiration,
    });

    factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        userId: json["userId"],
        role: json["role"],
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
        expiration: DateTime.parse(json["expiration"]),
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "role": role,
        "accessToken": accessToken,
        "refreshToken": refreshToken,
        "expiration": expiration.toIso8601String(),
    };
}
