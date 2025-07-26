import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/order_response.dart';
import 'package:silvercart/network/data/order_api_service.dart';
import 'package:silvercart/network/repositories/order/order_respository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: OrderRespository, env: [Environment.prod])
class OrderRespositoryApi implements OrderRespository {
  OrderApiService _api;
  OrderRespositoryApi(this._api);
  @override
  Future<BaseResponse<OrderResponse>> getOrders() async {
    try {
      final response = await _api.getOrders();
      return BaseResponse.success(data: response);
    } catch (e) {
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<OrderResponse>> getOrder(int id) async {
    try {
      final response = await _api.getOrder(id);
      return BaseResponse.success(data: response);
    } catch (e) {
      return BaseResponse.error(message: e.toString());
    }
  }
    
}