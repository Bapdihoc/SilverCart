// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDetailResponse _$ProductDetailResponseFromJson(
  Map<String, dynamic> json,
) => ProductDetailResponse(
  message: json['message'] as String,
  data: ProductDetailData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProductDetailResponseToJson(
  ProductDetailResponse instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};

ProductDetailData _$ProductDetailDataFromJson(
  Map<String, dynamic> json,
) => ProductDetailData(
  id: json['id'] as String,
  name: json['name'] as String,
  brand: json['brand'] as String,
  description: json['description'] as String,
  videoPath: json['videoPath'] as String?,
  weight: json['weight'] as String,
  height: json['height'] as String,
  length: json['length'] as String,
  width: json['width'] as String,
  manufactureDate: DateTime.parse(json['manufactureDate'] as String),
  expirationDate: DateTime.parse(json['expirationDate'] as String),
  categories:
      (json['categories'] as List<dynamic>)
          .map((e) => ProductDetailCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
  productVariants:
      (json['productVariants'] as List<dynamic>)
          .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
  styles:
      (json['styles'] as List<dynamic>)
          .map((e) => ProductStyle.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ProductDetailDataToJson(ProductDetailData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'description': instance.description,
      'videoPath': instance.videoPath,
      'weight': instance.weight,
      'height': instance.height,
      'length': instance.length,
      'width': instance.width,
      'manufactureDate': instance.manufactureDate.toIso8601String(),
      'expirationDate': instance.expirationDate.toIso8601String(),
      'categories': instance.categories,
      'productVariants': instance.productVariants,
      'styles': instance.styles,
    };

ProductDetailCategory _$ProductDetailCategoryFromJson(
  Map<String, dynamic> json,
) => ProductDetailCategory(
  id: json['id'] as String,
  code: json['code'] as String,
  description: json['description'] as String,
  label: json['label'] as String,
  type: (json['type'] as num).toInt(),
  listOfValueId: json['listOfValueId'] as String,
);

Map<String, dynamic> _$ProductDetailCategoryToJson(
  ProductDetailCategory instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'description': instance.description,
  'label': instance.label,
  'type': instance.type,
  'listOfValueId': instance.listOfValueId,
};

ProductVariant _$ProductVariantFromJson(
  Map<String, dynamic> json,
) => ProductVariant(
  id: json['id'] as String,
  price: (json['price'] as num).toDouble(),
  discount: (json['discount'] as num).toInt(),
  stock: (json['stock'] as num).toInt(),
  isActive: json['isActive'] as bool,
  productImages:
      (json['productImages'] as List<dynamic>)
          .map((e) => ProductVariantImage.fromJson(e as Map<String, dynamic>))
          .toList(),
  productVariantValues:
      (json['productVariantValues'] as List<dynamic>)
          .map((e) => ProductVariantValue.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ProductVariantToJson(ProductVariant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'price': instance.price,
      'discount': instance.discount,
      'stock': instance.stock,
      'isActive': instance.isActive,
      'productImages': instance.productImages,
      'productVariantValues': instance.productVariantValues,
    };

ProductVariantImage _$ProductVariantImageFromJson(Map<String, dynamic> json) =>
    ProductVariantImage(id: json['id'] as String, url: json['url'] as String);

Map<String, dynamic> _$ProductVariantImageToJson(
  ProductVariantImage instance,
) => <String, dynamic>{'id': instance.id, 'url': instance.url};

ProductVariantValue _$ProductVariantValueFromJson(Map<String, dynamic> json) =>
    ProductVariantValue(
      id: json['id'] as String,
      valueId: json['valueId'] as String,
      valueCode: json['valueCode'] as String,
      valueLabel: json['valueLabel'] as String,
    );

Map<String, dynamic> _$ProductVariantValueToJson(
  ProductVariantValue instance,
) => <String, dynamic>{
  'id': instance.id,
  'valueId': instance.valueId,
  'valueCode': instance.valueCode,
  'valueLabel': instance.valueLabel,
};

ProductStyle _$ProductStyleFromJson(Map<String, dynamic> json) => ProductStyle(
  listOfValueId: json['listOfValueId'] as String,
  label: json['label'] as String,
  options:
      (json['options'] as List<dynamic>)
          .map((e) => ProductStyleOption.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ProductStyleToJson(ProductStyle instance) =>
    <String, dynamic>{
      'listOfValueId': instance.listOfValueId,
      'label': instance.label,
      'options': instance.options,
    };

ProductStyleOption _$ProductStyleOptionFromJson(Map<String, dynamic> json) =>
    ProductStyleOption(
      id: json['id'] as String,
      label: json['label'] as String,
    );

Map<String, dynamic> _$ProductStyleOptionToJson(ProductStyleOption instance) =>
    <String, dynamic>{'id': instance.id, 'label': instance.label};
