import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/category_response.dart';
import 'package:silvercart/models/product_request.dart';
import 'package:silvercart/models/product_response.dart';
import 'package:silvercart/models/product_search_request.dart';
import 'package:silvercart/models/product_search_response.dart';
import 'package:silvercart/models/product_detail_response.dart';
import 'package:silvercart/network/repositories/product/product_repository.dart';

@LazySingleton()
class ProductService {
  final ProductRepository _repo;
  ProductService(this._repo);

  Future<BaseResponse<ProductResponse>> getProducts() async {
    return _repo.getProducts();
  }

  // Map API product to UI format
  Map<String, dynamic> mapProductToUI(Product product) {
    // Get the first active variant with items
    final activeVariant = product.variants.firstWhere(
      (v) => v.isActive && v.productItems.isNotEmpty,
      orElse: () => product.variants.first,
    );

    // Get the first product item (you might want to add logic to select specific item)
    final productItem = activeVariant.productItems.firstWhere(
      (item) => item.isActive && item.stock > 0,
      orElse: () => activeVariant.productItems.first,
    );

    // Get the first image or use emoji as fallback
    final firstImage = productItem.productImages.isNotEmpty 
        ? productItem.productImages.first 
        : null;

    // Map category to emoji
    final categoryEmoji = _getCategoryEmoji(product.productCategories);

    return {
      'id': product.id,
      'name': product.productName,
      'emoji': categoryEmoji,
      'price': productItem.discountedPrice.toInt(),
      'originalPrice': productItem.originalPrice != productItem.discountedPrice 
          ? productItem.originalPrice.toInt() 
          : null,
      'discount': productItem.originalPrice != productItem.discountedPrice 
          ? ((productItem.originalPrice - productItem.discountedPrice) / productItem.originalPrice * 100).round()
          : null,
      'rating': 4.5, // TODO: Add rating from API when available
      'reviews': 0, // TODO: Add reviews from API when available
      'category': categoryEmoji + ' ' + (product.productCategories.isNotEmpty 
          ? product.productCategories.first.categoryName 
          : 'Khác'),
      'description': product.description,
      'stock': productItem.stock,
      'sku': productItem.sku,
      'weight': productItem.weight,
      'imagePath': firstImage?.imagePath,
      'imageName': firstImage?.imageName,
      'productType': product.productType,
      'variantName': activeVariant.variantName,
    };
  }

  // Map category to emoji
  String _getCategoryEmoji(List<ProductCategory> categories) {
    if (categories.isEmpty) return '📦';
    
    final categoryName = categories.first.categoryName.toLowerCase();
    
    if (categoryName.contains('thực phẩm') || categoryName.contains('food')) return '🍎';
    if (categoryName.contains('thuốc') || categoryName.contains('medicine') || categoryName.contains('sức khỏe')) return '💊';
    if (categoryName.contains('chăm sóc') || categoryName.contains('care')) return '🧴';
    if (categoryName.contains('gia dụng') || categoryName.contains('household')) return '🏠';
    if (categoryName.contains('quần áo') || categoryName.contains('clothing')) return '👕';
    if (categoryName.contains('điện tử') || categoryName.contains('electronic')) return '📱';
    
    return '📦';
  }

  // Get products mapped to UI format
  Future<List<Map<String, dynamic>>> getProductsForUI() async {
    final result = await getProducts();
    
    if (result.isSuccess && result.data != null) {
      return result.data!.results.map((product) => mapProductToUI(product)).toList();
    }
    
    return [];
  }

  // Filter products by category
  List<Map<String, dynamic>> filterProductsByCategory(
    List<Map<String, dynamic>> products, 
    String selectedCategory
  ) {
    if (selectedCategory == 'Tất cả') return products;
    
    return products.where((product) {
      final productCategory = product['category'] as String;
      return productCategory.contains(selectedCategory.split(' ').skip(1).join(' '));
    }).toList();
  }

  // Filter products by search query
  List<Map<String, dynamic>> filterProductsBySearch(
    List<Map<String, dynamic>> products, 
    String searchQuery
  ) {
    if (searchQuery.isEmpty) return products;
    
    return products.where((product) {
      final name = product['name'].toString().toLowerCase();
      final description = product['description'].toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  Future<BaseResponse<Product>> getProduct(int id) async {
    return _repo.getProduct(id);
  }

  Future<BaseResponse<CategoryResponse>> getProductCategories(ProductRequest request) async {
    return _repo.getProductCategories(request);
  }

  Future<BaseResponse<ProductSearchResponse>> searchProducts(ProductSearchRequest request) async {
    return _repo.searchProducts(request);
  }

  Future<BaseResponse<ProductDetailResponse>> getProductDetail(String id) async {
    return _repo.getProductDetail(id);
  }

  // Map SearchProductItem from search API to UI format
  Map<String, dynamic> mapSearchProductToUI(SearchProductItem product) {
    // Get category emoji
    final categoryEmoji = _getSearchCategoryEmoji(product.categories);

    return {
      'id': product.id,
      'name': product.name,
      'emoji': categoryEmoji,
      'price': product.price.toInt(),
      'originalPrice': null, // No original price in search API
      'discount': null, // No discount in search API
      'rating': 4.5, // TODO: Add rating from API when available
      'reviews': 0, // TODO: Add reviews from API when available
      'category': categoryEmoji + ' ' + (product.categories.isNotEmpty 
          ? product.categories.first.label 
          : 'Khác'),
      'subCategory': product.categories.length > 1 ? product.categories[1].label : '',
      'description': product.description,
      'brand': product.brand,
      'imageUrl': product.imageUrl,
      'image': categoryEmoji, // Use emoji for now
    };
  }

  // Map category from search API to emoji
  String _getSearchCategoryEmoji(List<SearchProductCategory> categories) {
    if (categories.isEmpty) return '📦';
    
    final categoryLabel = categories.first.label.toLowerCase();
    
    if (categoryLabel.contains('di chuyển') || categoryLabel.contains('mobility')) return '🦯';
    if (categoryLabel.contains('sức khỏe') || categoryLabel.contains('health')) return '💊';
    if (categoryLabel.contains('chăm sóc') || categoryLabel.contains('care')) return '🧴';
    if (categoryLabel.contains('gia dụng') || categoryLabel.contains('household')) return '🏠';
    if (categoryLabel.contains('quần áo') || categoryLabel.contains('clothing')) return '👕';
    if (categoryLabel.contains('điện tử') || categoryLabel.contains('electronic')) return '📱';
    if (categoryLabel.contains('thực phẩm') || categoryLabel.contains('food')) return '🍎';
    
    return '📦';
  }

  // Search products and return UI format
  Future<List<Map<String, dynamic>>> searchProductsForUI(ProductSearchRequest request) async {
    final result = await searchProducts(request);
    
    if (result.isSuccess && result.data != null) {
      return result.data!.data.items.map((product) => mapSearchProductToUI(product)).toList();
    }
    
    return [];
  }
}