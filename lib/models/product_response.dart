// To parse this JSON data, do
//
//     final productResponse = productResponseFromJson(jsonString);

import 'dart:convert';

ProductResponse productResponseFromJson(String str) => ProductResponse.fromJson(json.decode(str));

String productResponseToJson(ProductResponse data) => json.encode(data.toJson());

class ProductResponse {
    int pageNumber;
    int pageSize;
    int totalNumberOfPages;
    int totalNumberOfRecords;
    List<Product> results;

    ProductResponse({
        required this.pageNumber,
        required this.pageSize,
        required this.totalNumberOfPages,
        required this.totalNumberOfRecords,
        required this.results,
    });

    factory ProductResponse.fromJson(Map<String, dynamic> json) => ProductResponse(
        pageNumber: json["pageNumber"],
        pageSize: json["pageSize"],
        totalNumberOfPages: json["totalNumberOfPages"],
        totalNumberOfRecords: json["totalNumberOfRecords"],
        results: List<Product>.from(json["results"].map((x) => Product.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "pageNumber": pageNumber,
        "pageSize": pageSize,
        "totalNumberOfPages": totalNumberOfPages,
        "totalNumberOfRecords": totalNumberOfRecords,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
    };
}

class Product {
    String id;
    String productName;
    String description;
    String videoPath;
    String productType;
    DateTime creationDate;
    List<ProductCategory> productCategories;
    List<Variant> variants;

    Product({
        required this.id,
        required this.productName,
        required this.description,
        required this.videoPath,
        required this.productType,
        required this.creationDate,
        required this.productCategories,
        required this.variants,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        productName: json["productName"],
        description: json["description"],
        videoPath: json["videoPath"],
        productType: json["productType"],
        creationDate: DateTime.parse(json["creationDate"]),
        productCategories: List<ProductCategory>.from(json["productCategories"].map((x) => ProductCategory.fromJson(x))),
        variants: List<Variant>.from(json["variants"].map((x) => Variant.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "productName": productName,
        "description": description,
        "videoPath": videoPath,
        "productType": productType,
        "creationDate": creationDate.toIso8601String(),
        "productCategories": List<dynamic>.from(productCategories.map((x) => x.toJson())),
        "variants": List<dynamic>.from(variants.map((x) => x.toJson())),
    };
}

class ProductCategory {
    String id;
    String categoryName;

    ProductCategory({
        required this.id,
        required this.categoryName,
    });

    factory ProductCategory.fromJson(Map<String, dynamic> json) => ProductCategory(
        id: json["id"],
        categoryName: json["categoryName"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "categoryName": categoryName,
    };
}

class Variant {
    String id;
    String variantName;
    bool isActive;
    List<ProductItem> productItems;

    Variant({
        required this.id,
        required this.variantName,
        required this.isActive,
        required this.productItems,
    });

    factory Variant.fromJson(Map<String, dynamic> json) => Variant(
        id: json["id"],
        variantName: json["variantName"],
        isActive: json["isActive"],
        productItems: List<ProductItem>.from(json["productItems"].map((x) => ProductItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "variantName": variantName,
        "isActive": isActive,
        "productItems": List<dynamic>.from(productItems.map((x) => x.toJson())),
    };
}

class ProductItem {
    String id;
    String sku;
    double originalPrice;
    double discountedPrice;
    int weight;
    int stock;
    bool isActive;
    List<ProductImage> productImages;

    ProductItem({
        required this.id,
        required this.sku,
        required this.originalPrice,
        required this.discountedPrice,
        required this.weight,
        required this.stock,
        required this.isActive,
        required this.productImages,
    });

    factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
        id: json["id"],
        sku: json["sku"],
        originalPrice: json["originalPrice"]?.toDouble(),
        discountedPrice: json["discountedPrice"]?.toDouble(),
        weight: json["weight"],
        stock: json["stock"],
        isActive: json["isActive"],
        productImages: List<ProductImage>.from(json["productImages"].map((x) => ProductImage.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "sku": sku,
        "originalPrice": originalPrice,
        "discountedPrice": discountedPrice,
        "weight": weight,
        "stock": stock,
        "isActive": isActive,
        "productImages": List<dynamic>.from(productImages.map((x) => x.toJson())),
    };
}

class ProductImage {
    String id;
    String imagePath;
    String imageName;

    ProductImage({
        required this.id,
        required this.imagePath,
        required this.imageName,
    });

    factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
        id: json["id"],
        imagePath: json["imagePath"],
        imageName: json["imageName"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "imagePath": imagePath,
        "imageName": imageName,
    };
}
