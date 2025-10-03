import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';
import 'package:silvercart/models/wallet_response.dart';
import 'package:silvercart/models/create_order_response.dart';
import 'package:silvercart/models/withdrawal_request.dart';
import 'package:silvercart/models/withdrawal_response.dart';

part 'wallet_api_service.g.dart';
class ParseErrorLogger {
  const ParseErrorLogger();
  void logError(Object error, StackTrace stackTrace, dynamic options) {
    // You can implement logging here, or leave it empty for now
  }
}
@module
abstract class WalletApiModule {
  @LazySingleton()
  WalletApiService provideWalletApiService(Dio dio) {
    final baseUrl = dotenv.env['BASE_URL'];
    return WalletApiService(dio, baseUrl: baseUrl);
  }
}

@RestApi()
abstract class WalletApiService {
  factory WalletApiService(Dio dio, {String? baseUrl}) = _WalletApiService;

  @GET('/api/Wallet/GetAmount')
  Future<WalletResponse> getWalletAmount(@Query('userId') String userId);

  @POST('/api/Wallet/TopUpByVnPay')
  Future<CreateOrderResponse> topUpByVnPay(@Body() Map<String, dynamic> body);

  @POST('/api/WithdrawRequest')
  Future<WithdrawalResponse> requestWithdrawal(@Body() WithdrawalRequest request);
}
