import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/wallet_response.dart';
import 'package:silvercart/models/create_order_response.dart';
import 'package:silvercart/network/repositories/wallet/wallet_repository.dart';

@LazySingleton()
class WalletService {
  final WalletRepository _repo;
  WalletService(this._repo);

  Future<BaseResponse<WalletResponse>> getWalletAmount(String userId) async {
    return _repo.getWalletAmount(userId);
  }

  Future<BaseResponse<CreateOrderResponse>> topUpByVnPay({required String userId, required int amount}) async {
    return _repo.topUpByVnPay(userId: userId, amount: amount);
  }
}
