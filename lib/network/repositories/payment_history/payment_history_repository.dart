import '../../../core/models/base_response.dart';
import '../../../models/payment_history_response.dart';

abstract class PaymentHistoryRepository {
  Future<BaseResponse<PaymentHistoryResponse>> searchPaymentHistory(PaymentHistorySearchRequest request);
}
