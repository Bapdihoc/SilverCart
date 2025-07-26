import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/category_response.dart';
import 'package:silvercart/models/product_request.dart';
import 'package:silvercart/models/product_response.dart';

abstract class ProductRepository {
  Future<BaseResponse<ProductResponse>> getProducts();
  Future<BaseResponse<Product>> getProduct(int id);
  Future<BaseResponse<CategoryResponse>> getProductCategories(ProductRequest request);
  Future<BaseResponse<CategoryModel>> getProductCategory(int id);
}