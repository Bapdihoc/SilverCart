import 'dart:convert';

class ElderResponse {
  final String message;
  final dynamic data;

  ElderResponse({
    required this.message,
    this.data,
  });

  factory ElderResponse.fromJson(Map<String, dynamic> json) {
    return ElderResponse(
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data,
    };
  }
}
