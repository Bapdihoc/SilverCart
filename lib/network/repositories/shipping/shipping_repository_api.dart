import 'package:dio/dio.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/shipping_fee_response.dart';
import 'package:silvercart/network/data/shipping_api_service.dart';
import 'package:silvercart/network/data/api_response_handler.dart';
import 'package:silvercart/network/repositories/shipping/shipping_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ShippingRepository, env: [Environment.prod])
class ShippingRepositoryApi implements ShippingRepository {
  final ShippingApiService _api;
  
  ShippingRepositoryApi(this._api);

  @override
  Future<BaseResponse<ShippingFeeResponse>> recalcShippingFee(String addressId) async {
    try {
      final response = await _api.recalcShippingFee(addressId);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<ShippingFeeResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }
}
