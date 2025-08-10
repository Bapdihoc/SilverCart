import 'dart:convert';

class DistrictResponse {
  final String message;
  final List<District> data;

  DistrictResponse({
    required this.message,
    required this.data,
  });

  factory DistrictResponse.fromJson(Map<String, dynamic> json) {
    return DistrictResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => District.fromJson(item))
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

class District {
  final int districtID;
  final int provinceID;
  final String districtName;
  final String code;
  final int type;
  final int supportType;
  final String id;
  final bool isDeleted;
  final DateTime? creationDate;
  final DateTime? modificationDate;
  final DateTime? deletionDate;
  final String? createdById;
  final String? modificationById;
  final String? deleteById;
  final String rowVersion;

  District({
    required this.districtID,
    required this.provinceID,
    required this.districtName,
    required this.code,
    required this.type,
    required this.supportType,
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

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      districtID: json['districtID'] ?? 0,
      provinceID: json['provinceID'] ?? 0,
      districtName: json['districtName'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? 0,
      supportType: json['supportType'] ?? 0,
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
      'districtID': districtID,
      'provinceID': provinceID,
      'districtName': districtName,
      'code': code,
      'type': type,
      'supportType': supportType,
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
