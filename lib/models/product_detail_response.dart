import 'package:json_annotation/json_annotation.dart';

part 'product_detail_response.g.dart';

@JsonSerializable()
class ProductDetailResponse {
  final String message;
  final ProductDetailData data;

  ProductDetailResponse({required this.message, required this.data});

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) => _$ProductDetailResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProductDetailResponseToJson(this);
}

@JsonSerializable()
class ProductDetailData {
  final String id;
  final String name;
  final String brand;
  final String description;
  final String? videoPath;
  final String weight;
  final String height;
  final String length;
  final String width;
  final DateTime manufactureDate;
  final DateTime expirationDate;
  final List<ProductDetailCategory> categories;
  final List<ProductVariant> productVariants;
  final List<ProductStyle> styles;

  ProductDetailData({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    this.videoPath,
    required this.weight,
    required this.height,
    required this.length,
    required this.width,
    required this.manufactureDate,
    required this.expirationDate,
    required this.categories,
    required this.productVariants,
    required this.styles,
  });

  factory ProductDetailData.fromJson(Map<String, dynamic> json) => _$ProductDetailDataFromJson(json);
  Map<String, dynamic> toJson() => _$ProductDetailDataToJson(this);
}

@JsonSerializable()
class ProductDetailCategory {
  final String id;
  final String code;
  final String description;
  final String label;
  final int type;
  final String listOfValueId;

  ProductDetailCategory({
    required this.id,
    required this.code,
    required this.description,
    required this.label,
    required this.type,
    required this.listOfValueId,
  });

  factory ProductDetailCategory.fromJson(Map<String, dynamic> json) => _$ProductDetailCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$ProductDetailCategoryToJson(this);
}

@JsonSerializable()
class ProductVariant {
  final String id;
  final double price;
  final int discount;
  final int stock;
  final bool isActive;
  final List<ProductVariantImage> productImages;
  final List<ProductVariantValue> productVariantValues;

  ProductVariant({
    required this.id,
    required this.price,
    required this.discount,
    required this.stock,
    required this.isActive,
    required this.productImages,
    required this.productVariantValues,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) => _$ProductVariantFromJson(json);
  Map<String, dynamic> toJson() => _$ProductVariantToJson(this);

  double get discountedPrice => price * (1 - discount / 100);
  double get originalPrice => price;
}

@JsonSerializable()
class ProductVariantImage {
  final String id;
  final String url;

  ProductVariantImage({
    required this.id,
    required this.url,
  });

  factory ProductVariantImage.fromJson(Map<String, dynamic> json) => _$ProductVariantImageFromJson(json);
  Map<String, dynamic> toJson() => _$ProductVariantImageToJson(this);
}

@JsonSerializable()
class ProductVariantValue {
  final String id;
  final String valueId;
  final String valueCode;
  final String valueLabel;

  ProductVariantValue({
    required this.id,
    required this.valueId,
    required this.valueCode,
    required this.valueLabel,
  });

  factory ProductVariantValue.fromJson(Map<String, dynamic> json) => _$ProductVariantValueFromJson(json);
  Map<String, dynamic> toJson() => _$ProductVariantValueToJson(this);
}

@JsonSerializable()
class ProductStyle {
  final String listOfValueId;
  final String label;
  final List<ProductStyleOption> options;

  ProductStyle({
    required this.listOfValueId,
    required this.label,
    required this.options,
  });

  factory ProductStyle.fromJson(Map<String, dynamic> json) => _$ProductStyleFromJson(json);
  Map<String, dynamic> toJson() => _$ProductStyleToJson(this);
}

@JsonSerializable()
class ProductStyleOption {
  final String id;
  final String label;

  ProductStyleOption({
    required this.id,
    required this.label,
  });

  factory ProductStyleOption.fromJson(Map<String, dynamic> json) => _$ProductStyleOptionFromJson(json);
  Map<String, dynamic> toJson() => _$ProductStyleOptionToJson(this);
}
