import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/order_response.dart';
import 'package:silvercart/models/create_order_request.dart';
import 'package:silvercart/models/create_order_response.dart';
import 'package:silvercart/models/user_order_response.dart';
import 'package:silvercart/models/order_statistic_response.dart';
import 'package:silvercart/models/elder_order_response.dart';
import 'package:silvercart/models/elder_budget_statistic_response.dart';
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

  Future<BaseResponse<CreateOrderResponse>> checkoutByWallet(CreateOrderRequest request) async {
    return await _repo.checkoutByWallet(request);
  }

  Future<BaseResponse<UserOrderResponse>> getUserOrders() async {
    return await _repo.getUserOrders();
  }

  Future<BaseResponse<OrderStatisticResponse>> getUserStatistic(String userId) async {
    return await _repo.getUserStatistic(userId);
  }

  Future<BaseResponse<void>> cancelOrder(String orderId, String cancelReason) async {
    return await _repo.cancelOrder(orderId, cancelReason);
  }

  Future<BaseResponse<ElderOrderResponse>> getOrdersByElder() async {
    return await _repo.getOrdersByElder();
  }

  Future<BaseResponse<ElderBudgetStatisticResponse>> getElderBudgetStatistic(
    String customerId, 
    String fromDate, 
    String toDate,
  ) async {
    return await _repo.getElderBudgetStatistic(customerId, fromDate, toDate);
  }
}
