import 'dart:convert';
import 'dart:developer';

import 'package:injectable/injectable.dart';
import '../../core/models/base_response.dart';
import '../../models/payment_history_response.dart';
import '../repositories/payment_history/payment_history_repository.dart';

@lazySingleton
class PaymentHistoryService {
  final PaymentHistoryRepository _repository;

  PaymentHistoryService(this._repository);

  Future<BaseResponse<PaymentHistoryResponse>> searchPaymentHistory(
      PaymentHistorySearchRequest request) async {
        log('requestA: ${jsonEncode(request)}');
    return await _repository.searchPaymentHistory(request);
  }
}
