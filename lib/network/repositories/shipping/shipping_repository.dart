import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/shipping_fee_response.dart';

abstract class ShippingRepository {
  Future<BaseResponse<ShippingFeeResponse>> recalcShippingFee(String addressId);
}
