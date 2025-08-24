import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';
import 'package:silvercart/models/shipping_fee_response.dart';

part 'shipping_api_service.g.dart';

class ParseErrorLogger {
  const ParseErrorLogger();
  void logError(Object error, StackTrace stackTrace, dynamic options) {
    // You can implement logging here, or leave it empty for now
  }
}

@module
abstract class ShippingApiModule {
  @LazySingleton()
  ShippingApiService provideShippingApiService(Dio dio) {
    final baseUrl = dotenv.env['BASE_URL'];
    return ShippingApiService(dio, baseUrl: baseUrl);
  }
}

@RestApi()
abstract class ShippingApiService {
  factory ShippingApiService(Dio dio, {String? baseUrl}) = _ShippingApiService;

  @POST('/api/Shipping/{addressId}/RecalcFeeDefault')
  Future<ShippingFeeResponse> recalcShippingFee(@Path('addressId') String addressId);
}
