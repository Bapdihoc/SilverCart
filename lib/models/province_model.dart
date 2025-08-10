// To parse this JSON data, do
//
//     final provinceResponse = provinceResponseFromJson(jsonString);

import 'dart:convert';

ProvinceResponse provinceResponseFromJson(String str) => ProvinceResponse.fromJson(json.decode(str));

String provinceResponseToJson(ProvinceResponse data) => json.encode(data.toJson());

class ProvinceResponse {
    String message;
    List<Province> data;

    ProvinceResponse({
        required this.message,
        required this.data,
    });

    factory ProvinceResponse.fromJson(Map<String, dynamic> json) => ProvinceResponse(
        message: json["message"],
        data: List<Province>.from(json["data"].map((x) => Province.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Province {
    int provinceID;
    String provinceName;
    String code;
    String id;
    bool isDeleted;
    DateTime? creationDate;
    DateTime? modificationDate;
    DateTime? deletionDate;
    String? createdById;
    String? modificationById;
    String? deleteById;
    String rowVersion;

    Province({
        required this.provinceID,
        required this.provinceName,
        required this.code,
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

    factory Province.fromJson(Map<String, dynamic> json) => Province(
        provinceID: json["provinceID"],
        provinceName: json["provinceName"],
        code: json["code"],
        id: json["id"],
        isDeleted: json["isDeleted"],
        creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
        modificationDate: json["modificationDate"] == null ? null : DateTime.parse(json["modificationDate"]),
        deletionDate: json["deletionDate"] == null ? null : DateTime.parse(json["deletionDate"]),
        createdById: json["createdById"],
        modificationById: json["modificationById"],
        deleteById: json["deleteById"],
        rowVersion: json["rowVersion"],
    );

    Map<String, dynamic> toJson() => {
        "provinceID": provinceID,
        "provinceName": provinceName,
        "code": code,
        "id": id,
        "isDeleted": isDeleted,
        "creationDate": creationDate?.toIso8601String(),
        "modificationDate": modificationDate?.toIso8601String(),
        "deletionDate": deletionDate?.toIso8601String(),
        "createdById": createdById,
        "modificationById": modificationById,
        "deleteById": deleteById,
        "rowVersion": rowVersion,
    };
}
