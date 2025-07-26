// To parse this JSON data, do
//
//     final categoryResponse = categoryResponseFromJson(jsonString);

import 'dart:convert';

CategoryResponse categoryResponseFromJson(String str) => CategoryResponse.fromJson(json.decode(str));

String categoryResponseToJson(CategoryResponse data) => json.encode(data.toJson());

class CategoryResponse {
    int pageNumber;
    int pageSize;
    int totalNumberOfPages;
    int totalNumberOfRecords;
    List<CategoryModel> results;

    CategoryResponse({
        required this.pageNumber,
        required this.pageSize,
        required this.totalNumberOfPages,
        required this.totalNumberOfRecords,
        required this.results,
    });

    factory CategoryResponse.fromJson(Map<String, dynamic> json) => CategoryResponse(
        pageNumber: json["pageNumber"],
        pageSize: json["pageSize"],
        totalNumberOfPages: json["totalNumberOfPages"],
        totalNumberOfRecords: json["totalNumberOfRecords"],
        results: List<CategoryModel>.from(json["results"].map((x) => CategoryModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "pageNumber": pageNumber,
        "pageSize": pageSize,
        "totalNumberOfPages": totalNumberOfPages,
        "totalNumberOfRecords": totalNumberOfRecords,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
    };
}

class CategoryModel {
    String id;
    String name;
    String description;
    String status;
    String parentCategoryId;
    String parentCategoryName;
    DateTime creationDate;
    int productCount;

    CategoryModel({
        required this.id,
        required this.name,
        required this.description,
        required this.status,
        required this.parentCategoryId,
        required this.parentCategoryName,
        required this.creationDate,
        required this.productCount,
    });

    factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        status: json["status"],
        parentCategoryId: json["parentCategoryId"],
        parentCategoryName: json["parentCategoryName"],
        creationDate: DateTime.parse(json["creationDate"]),
        productCount: json["productCount"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "status": status,
        "parentCategoryId": parentCategoryId,
        "parentCategoryName": parentCategoryName,
        "creationDate": creationDate.toIso8601String(),
        "productCount": productCount,
    };
}
