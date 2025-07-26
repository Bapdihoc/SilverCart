import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';
import 'package:silvercart/models/category_response.dart';
import 'package:silvercart/models/product_response.dart';
part 'product_api_service.g.dart';

class ParseErrorLogger {
  const ParseErrorLogger();
  void logError(Object error, StackTrace stackTrace, dynamic options) {
    // You can implement logging here, or leave it empty for now
  }
}

@module
abstract class ProductApiModule {
  @LazySingleton()
  ProductApiService provideProductApiService(Dio dio) {
    final baseUrl = dotenv.env['BASE_URL'];
    return ProductApiService(dio, baseUrl: baseUrl);
  }
}

@RestApi()
abstract class ProductApiService {
  factory ProductApiService(Dio dio, {String? baseUrl}) = _ProductApiService;

  @GET('/api/Product')
  Future<ProductResponse> getProducts();

  @GET('/api/Product/{id}')
  Future<Product> getProduct(@Path('id') int id);

  @GET('/api/Product/category')
  Future<CategoryResponse> getProductCategories(@Queries() Map<String, dynamic> params);

  @GET('/api/Product/category/{id}')
  Future<CategoryModel> getProductCategory(@Path('id') int id);
  
}