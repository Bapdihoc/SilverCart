import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';
import 'package:silvercart/models/order_response.dart';
import 'package:silvercart/models/create_order_request.dart';
import 'package:silvercart/models/create_order_response.dart';
import 'package:silvercart/models/user_order_response.dart';
import 'package:silvercart/models/order_statistic_response.dart';
import 'package:silvercart/models/elder_order_response.dart';
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

  @POST('/api/Order/CancelOrder')
  Future<void> cancelOrder(@Body() Map<String, String> body);

  @GET('/api/Order')
  Future<OrderResponse> getOrders();

  @GET('/api/Order/{id}')
  Future<OrderResponse> getOrder(@Path('id') int id);

  @POST('/api/Order/VnPay')
  Future<CreateOrderResponse> createOrder(@Body() CreateOrderRequest request);

  @POST('/api/Order/CheckoutByWallet')
  Future<CreateOrderResponse> checkoutByWallet(@Body() CreateOrderRequest request);

  @GET('/api/Order/user')
  Future<UserOrderResponse> getUserOrders();
  
  @GET('/api/Order/GetUserStatistic/{userId}')
  Future<OrderStatisticResponse> getUserStatistic(@Path('userId') String userId);
  
  @GET('/api/Order/GetOrdersByElder')
  Future<ElderOrderResponse> getOrdersByElder();
  
}