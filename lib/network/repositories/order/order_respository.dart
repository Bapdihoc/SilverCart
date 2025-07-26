import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/order_response.dart';

abstract class OrderRespository {
  Future<BaseResponse<OrderResponse>> getOrders();
  Future<BaseResponse<OrderResponse>> getOrder(int id);
  // Future<BaseResponse<Order>> createOrder();

}