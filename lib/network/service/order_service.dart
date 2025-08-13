import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/order_response.dart';
import 'package:silvercart/models/create_order_request.dart';
import 'package:silvercart/models/create_order_response.dart';
import 'package:silvercart/models/user_order_response.dart';
import 'package:silvercart/network/repositories/order/order_respository.dart';

@LazySingleton()
class OrderService {
  final OrderRespository _repo;
  
  OrderService(this._repo);

  Future<BaseResponse<OrderResponse>> getOrders() async {
    return await _repo.getOrders();
  }

  Future<BaseResponse<OrderResponse>> getOrder(int id) async {
    return await _repo.getOrder(id);
  }

  Future<BaseResponse<CreateOrderResponse>> createOrder(CreateOrderRequest request) async {
    return await _repo.createOrder(request);
  }

  Future<BaseResponse<UserOrderResponse>> getUserOrders() async {
    return await _repo.getUserOrders();
  }
}
