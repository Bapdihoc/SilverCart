// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
    String message;
    String data; // JWT token

    LoginResponse({
        required this.message,
        required this.data,
    });

    factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        message: json["message"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data,
    };

    // Helper method to decode JWT token and extract user info
    Map<String, dynamic>? getDecodedToken() {
        try {
            final parts = data.split('.');
            if (parts.length != 3) return null;
            
            // Decode the payload part (second part)
            final payload = parts[1];
            // Add padding if needed
            final normalized = base64Url.normalize(payload);
            final resp = utf8.decode(base64Url.decode(normalized));
            final payloadMap = json.decode(resp);
            return payloadMap;
        } catch (e) {
            return null;
        }
    }

    // Get user ID from JWT token
    String? getUserId() {
        final decoded = getDecodedToken();
        return decoded?['UserId'];
    }

    // Get user name from JWT token
    String? getUserName() {
        final decoded = getDecodedToken();
        return decoded?['UserName'];
    }

    // Get role from JWT token
    String? getRole() {
        final decoded = getDecodedToken();
        return decoded?['Role'];
    }

    // Get expiration from JWT token
    DateTime? getExpiration() {
        final decoded = getDecodedToken();
        if (decoded?['exp'] != null) {
            return DateTime.fromMillisecondsSinceEpoch(decoded!['exp'] * 1000);
        }
        return null;
    }
}
