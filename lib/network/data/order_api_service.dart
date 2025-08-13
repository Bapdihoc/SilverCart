import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';
import 'package:silvercart/models/category_response.dart';
import 'package:silvercart/models/order_response.dart';
import 'package:silvercart/models/product_response.dart';
import 'package:silvercart/models/create_order_request.dart';
import 'package:silvercart/models/create_order_response.dart';
import 'package:silvercart/models/user_order_response.dart';
part 'order_api_service.g.dart';

class ParseErrorLogger {
  const ParseErrorLogger();
  void logError(Object error, StackTrace stackTrace, dynamic options) {
    // You can implement logging here, or leave it empty for now
  }
}

@module
abstract class OrderApiModule {
  @LazySingleton()
  OrderApiService provideOrderApiService(Dio dio) {
    final baseUrl = dotenv.env['BASE_URL'];
    return OrderApiService(dio, baseUrl: baseUrl);
  }
}

@RestApi()
abstract class OrderApiService {
  factory OrderApiService(Dio dio, {String? baseUrl}) = _OrderApiService;

  @GET('/api/Order')
  Future<OrderResponse> getOrders();

  @GET('/api/Order/{id}')
  Future<OrderResponse> getOrder(@Path('id') int id);

  @POST('/api/Test/CreateOrder')
  Future<CreateOrderResponse> createOrder(@Body() CreateOrderRequest request);

  @GET('/api/Order/user')
  Future<UserOrderResponse> getUserOrders();
  
}