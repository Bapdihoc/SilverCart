import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/create_order_response.dart';
import 'package:silvercart/models/wallet_response.dart';
import 'package:silvercart/network/data/api_response_handler.dart';
import 'package:silvercart/network/data/wallet_api_service.dart';
import 'wallet_repository.dart';

@Environment('prod')
@LazySingleton(as: WalletRepository)
class WalletRepositoryApi implements WalletRepository {
  final WalletApiService _apiService;

  WalletRepositoryApi(this._apiService);

  @override
  Future<BaseResponse<WalletResponse>> getWalletAmount(String userId) async {
    try {
      final response = await _apiService.getWalletAmount(userId);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<WalletResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<CreateOrderResponse>> topUpByVnPay({required String userId, required int amount}) async {
    try {
      final response = await _apiService.topUpByVnPay({
        'userId': userId,
        'amount': amount,
      });
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<CreateOrderResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }
}
