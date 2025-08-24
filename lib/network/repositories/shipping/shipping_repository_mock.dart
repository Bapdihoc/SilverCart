import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/shipping_fee_response.dart';
import 'package:silvercart/network/repositories/shipping/shipping_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ShippingRepository, env: [Environment.dev])
class ShippingRepositoryMock implements ShippingRepository {
  @override
  Future<BaseResponse<ShippingFeeResponse>> recalcShippingFee(String addressId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock response
    final mockResponse = ShippingFeeResponse(
      message: 'Recalculate fee successfully',
      data: ShippingFeeData(fee: 20500),
    );
    
    return BaseResponse.success(data: mockResponse);
  }
}
