class ProductSearchResponse {
  final String message;
  final ProductSearchData data;

  ProductSearchResponse({
    required this.message,
    required this.data,
  });

  factory ProductSearchResponse.fromJson(Map<String, dynamic> json) {
    return ProductSearchResponse(
      message: json['message'] ?? '',
      data: ProductSearchData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ProductSearchData {
  final int totalItems;
  final int page;
  final int pageSize;
  final List<SearchProductItem> items;

  ProductSearchData({
    required this.totalItems,
    required this.page,
    required this.pageSize,
    required this.items,
  });

  factory ProductSearchData.fromJson(Map<String, dynamic> json) {
    return ProductSearchData(
      totalItems: json['totalItems'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => SearchProductItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'page': page,
      'pageSize': pageSize,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class SearchProductItem {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String description;
  final String imageUrl;
  final List<SearchProductCategory> categories;

  SearchProductItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.categories,
  });

  factory SearchProductItem.fromJson(Map<String, dynamic> json) {
    return SearchProductItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      categories: (json['categories'] as List<dynamic>?)
          ?.map((category) => SearchProductCategory.fromJson(category as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }
}

class SearchProductCategory {
  final String id;
  final String code;
  final String description;
  final String label;
  final int type;
  final String listOfValueId;

  SearchProductCategory({
    required this.id,
    required this.code,
    required this.description,
    required this.label,
    required this.type,
    required this.listOfValueId,
  });

  factory SearchProductCategory.fromJson(Map<String, dynamic> json) {
    return SearchProductCategory(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 0,
      listOfValueId: json['listOfValueId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'label': label,
      'type': type,
      'listOfValueId': listOfValueId,
    };
  }
}
