import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:silvercart/models/cart_replace_request.dart';
import 'package:silvercart/models/cart_replace_response.dart';
import 'package:silvercart/models/cart_get_response.dart';
import 'package:silvercart/models/change_cart_status_response.dart';
import 'package:silvercart/models/elder_carts_response.dart';

part 'cart_api_service.g.dart';

class ParseErrorLogger {
  const ParseErrorLogger();
  void logError(Object error, StackTrace stackTrace, dynamic options) {
    // You can implement logging here, or leave it empty for now
  }
}

@module
abstract class CartApiModule {
  @LazySingleton()
  CartApiService provideCartApiService(Dio dio) {
    final baseUrl = dotenv.env['BASE_URL'];
    return CartApiService(dio, baseUrl: baseUrl);
  }
}

@RestApi()
abstract class CartApiService {
  factory CartApiService(Dio dio, {String? baseUrl}) = _CartApiService;

  @POST('/api/Cart/ReplaceAllCart')
  Future<CartReplaceResponse> replaceAllCart(@Body() CartReplaceRequest request);

  @GET('/api/Cart/GetCartByCustomerId/{customerId}')
  Future<CartGetResponse> getCartByCustomerId(
    @Path('customerId') String customerId,
    @Query('status') int status,
  );

  @GET('/api/Cart/GetCartByElderId/{elderId}')
  Future<CartGetResponse> getCartByElderId(
    @Path('elderId') String elderId,
    @Query('status') int status,
  );

  @PUT('/api/Cart/{cartId}/ChangeCartStatus')
  Future<ChangeCartStatusResponse> changeCartStatus(
    @Path('cartId') String cartId,
    @Query('status') int status,
  );

  @GET('/api/Cart/GetAllElderCarts')
  Future<ElderCartsResponse> getAllElderCarts();
}
