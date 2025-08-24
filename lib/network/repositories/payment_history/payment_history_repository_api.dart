import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/models/base_response.dart';
import '../../../models/payment_history_response.dart';
import '../../data/api_response_handler.dart';
import '../../data/payment_history_api_service.dart';
import 'payment_history_repository.dart';

@LazySingleton(as: PaymentHistoryRepository, env: [Environment.prod])
class PaymentHistoryRepositoryApi implements PaymentHistoryRepository {
  final PaymentHistoryApiService _apiService;

  PaymentHistoryRepositoryApi(this._apiService);

  @override
  Future<BaseResponse<PaymentHistoryResponse>> searchPaymentHistory(
      PaymentHistorySearchRequest request) async {
    try {
      final response = await _apiService.searchPaymentHistory(request);
      return BaseResponse.success(data: response);
    } on DioException catch (e) {
      return ApiResponseHandler.handleError<PaymentHistoryResponse>(e);
    } catch (e) {
      return BaseResponse.error(message: e.toString());
    }
  }
}
