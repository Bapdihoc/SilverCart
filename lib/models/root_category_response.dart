class RootCategoryResponse {
  final String message;
  final List<RootCategory> data;

  RootCategoryResponse({
    required this.message,
    required this.data,
  });

  factory RootCategoryResponse.fromJson(Map<String, dynamic> json) {
    return RootCategoryResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => RootCategory.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class RootCategory {
  final String id;
  final String code;
  final String description;
  final String label;
  final int type;
  final String? childrenId;
  final String? childrentLabel;

  RootCategory({
    required this.id,
    required this.code,
    required this.description,
    required this.label,
    required this.type,
    this.childrenId,
    this.childrentLabel,
  });

  factory RootCategory.fromJson(Map<String, dynamic> json) {
    return RootCategory(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 0,
      childrenId: json['childrenId'],
      childrentLabel: json['childrentLabel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'label': label,
      'type': type,
      'childrenId': childrenId,
      'childrentLabel': childrentLabel,
    };
  }
}
