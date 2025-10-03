import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/wallet_response.dart';
import 'package:silvercart/models/create_order_response.dart';
import 'package:silvercart/models/withdrawal_request.dart';
import 'package:silvercart/models/withdrawal_response.dart';

abstract class WalletRepository {
  Future<BaseResponse<WalletResponse>> getWalletAmount(String userId);
  Future<BaseResponse<CreateOrderResponse>> topUpByVnPay({required String userId, required int amount});
  Future<BaseResponse<WithdrawalResponse>> requestWithdrawal(WithdrawalRequest request);
}
