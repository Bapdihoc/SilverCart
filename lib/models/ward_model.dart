import 'dart:convert';

class WardResponse {
  final String message;
  final List<Ward> data;

  WardResponse({
    required this.message,
    required this.data,
  });

  factory WardResponse.fromJson(Map<String, dynamic> json) {
    return WardResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => Ward.fromJson(item))
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

class Ward {
  final String wardCode;
  final int districtID;
  final String wardName;
  final String id;
  final bool isDeleted;
  final DateTime? creationDate;
  final DateTime? modificationDate;
  final DateTime? deletionDate;
  final String? createdById;
  final String? modificationById;
  final String? deleteById;
  final String rowVersion;

  Ward({
    required this.wardCode,
    required this.districtID,
    required this.wardName,
    required this.id,
    required this.isDeleted,
    this.creationDate,
    this.modificationDate,
    this.deletionDate,
    this.createdById,
    this.modificationById,
    this.deleteById,
    required this.rowVersion,
  });

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      wardCode: json['wardCode'] ?? '',
      districtID: json['districtID'] ?? 0,
      wardName: json['wardName'] ?? '',
      id: json['id'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      creationDate: json['creationDate'] != null 
          ? DateTime.parse(json['creationDate']) 
          : null,
      modificationDate: json['modificationDate'] != null 
          ? DateTime.parse(json['modificationDate']) 
          : null,
      deletionDate: json['deletionDate'] != null 
          ? DateTime.parse(json['deletionDate']) 
          : null,
      createdById: json['createdById'],
      modificationById: json['modificationById'],
      deleteById: json['deleteById'],
      rowVersion: json['rowVersion'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wardCode': wardCode,
      'districtID': districtID,
      'wardName': wardName,
      'id': id,
      'isDeleted': isDeleted,
      'creationDate': creationDate?.toIso8601String(),
      'modificationDate': modificationDate?.toIso8601String(),
      'deletionDate': deletionDate?.toIso8601String(),
      'createdById': createdById,
      'modificationById': modificationById,
      'deleteById': deleteById,
      'rowVersion': rowVersion,
    };
  }
}
