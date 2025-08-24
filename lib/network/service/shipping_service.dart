import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/shipping_fee_response.dart';
import 'package:silvercart/network/repositories/shipping/shipping_repository.dart';

@LazySingleton()
class ShippingService {
  final ShippingRepository _repo;
  
  ShippingService(this._repo);

  Future<BaseResponse<ShippingFeeResponse>> recalcShippingFee(String addressId) async {
    return await _repo.recalcShippingFee(addressId);
  }
}
