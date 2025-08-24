import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/payment_history_response.dart';

part 'payment_history_api_service.g.dart';

@RestApi()
abstract class PaymentHistoryApiService {
  factory PaymentHistoryApiService(Dio dio) = _PaymentHistoryApiService;

  @POST('/api/PaymentHistory/Search')
  Future<PaymentHistoryResponse> searchPaymentHistory(
    @Body() PaymentHistorySearchRequest request,
  );
}
