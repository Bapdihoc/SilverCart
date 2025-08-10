import 'dart:convert';

class CategoryListResponse {
  final String message;
  final List<Category> data;

  CategoryListResponse({
    required this.message,
    required this.data,
  });

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    return CategoryListResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => Category.fromJson(item as Map<String, dynamic>))
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

class Category {
  final String id;
  final String label;
  final String note;
  final int type;
  final List<CategoryValue> values;

  Category({
    required this.id,
    required this.label,
    required this.note,
    required this.type,
    required this.values,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      note: json['note'] ?? '',
      type: json['type'] ?? 0,
      values: (json['values'] as List<dynamic>?)
          ?.map((item) => CategoryValue.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'note': note,
      'type': type,
      'values': values.map((item) => item.toJson()).toList(),
    };
  }
}

class CategoryValue {
  final String id;
  final String code;
  final String description;
  final String label;
  final int type;
  final String? childrenId;
  final String? childrentLabel;

  CategoryValue({
    required this.id,
    required this.code,
    required this.description,
    required this.label,
    required this.type,
    this.childrenId,
    this.childrentLabel,
  });

  factory CategoryValue.fromJson(Map<String, dynamic> json) {
    return CategoryValue(
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
