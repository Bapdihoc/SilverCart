import 'package:injectable/injectable.dart';
import 'package:silvercart/models/create_order_response.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/wallet_response.dart';
import 'package:silvercart/models/withdrawal_request.dart';
import 'package:silvercart/models/withdrawal_response.dart';
import 'wallet_repository.dart';

@Environment('dev')
@LazySingleton(as: WalletRepository)
class WalletRepositoryMock implements WalletRepository {
  @override
  Future<BaseResponse<WalletResponse>> getWalletAmount(String userId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock response
    final mockResponse = WalletResponse(
      message: "Wallet amount retrieved successfully",
      data: WalletData(amount: 3446200),
    );
    
    return BaseResponse.success(data: mockResponse);
  }

  @override
  Future<BaseResponse<CreateOrderResponse>> topUpByVnPay({required String userId, required int amount}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return BaseResponse.success(
      data: CreateOrderResponse(
        message: 'VNPay URL generated (mock)',
        data: 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?mock=true',
      ),
    );
  }

  @override
  Future<BaseResponse<WithdrawalResponse>> requestWithdrawal(WithdrawalRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return BaseResponse.success(data: WithdrawalResponse(message: 'Withdrawal request successful', data: null));
  }
}
