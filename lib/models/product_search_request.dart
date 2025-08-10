class ProductSearchRequest {
  final String? keyword;
  final List<String>? categoryIds;
  final int? page;
  final int? pageSize;

  ProductSearchRequest({
    this.keyword,
    this.categoryIds,
    this.page,
    this.pageSize,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (keyword != null) {
      data['keyword'] = keyword;
    }
    
    if (categoryIds != null && categoryIds!.isNotEmpty) {
      data['categoryIds'] = categoryIds;
    }
    
    if (page != null) {
      data['page'] = page;
    }
    
    if (pageSize != null) {
      data['pageSize'] = pageSize;
    }
    
    return data;
  }
}
