import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/category_response.dart';
import 'package:silvercart/models/product_request.dart';
import 'package:silvercart/models/product_response.dart';
import 'package:silvercart/models/product_search_request.dart';
import 'package:silvercart/models/product_search_response.dart';
import 'package:silvercart/models/product_detail_response.dart';
import 'package:silvercart/network/data/product_api_service.dart';
import 'package:silvercart/network/data/api_response_handler.dart';
import 'package:silvercart/network/repositories/product/product_repository.dart';

@LazySingleton(as: ProductRepository, env: [Environment.prod])
class ProductRepositoryApi implements ProductRepository {
  final ProductApiService _apiService;
  ProductRepositoryApi(this._apiService);

  @override
  Future<BaseResponse<ProductResponse>> getProducts() async {
    try {
      final response = await _apiService.getProducts();
      return BaseResponse.success(data: response);
    } catch (e) {
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<Product>> getProduct(int id) async {
    try {
      final response = await _apiService.getProduct(id);
      return BaseResponse.success(data: response);
    } catch (e) {
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<CategoryResponse>> getProductCategories(ProductRequest request) async {
    try {
      final response = await _apiService.getProductCategories(request.toJson());
      return BaseResponse.success(data: response);
    } catch (e) {
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<CategoryModel>> getProductCategory(int id) async {
    try {
      final response = await _apiService.getProductCategory(id);
      return BaseResponse.success(data: response);
    } catch (e) {
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<ProductSearchResponse>> searchProducts(ProductSearchRequest request) async {
    try {
      final response = await _apiService.searchProducts(request.toJson());
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<ProductSearchResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<ProductDetailResponse>> getProductDetail(String id) async {
    try {
      final response = await _apiService.getProductDetail(id);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<ProductDetailResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }
}