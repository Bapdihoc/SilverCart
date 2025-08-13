import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/order_response.dart';
import 'package:silvercart/models/create_order_request.dart';
import 'package:silvercart/models/create_order_response.dart';
import 'package:silvercart/models/user_order_response.dart';

abstract class OrderRespository {
  Future<BaseResponse<OrderResponse>> getOrders();
  Future<BaseResponse<OrderResponse>> getOrder(int id);
  Future<BaseResponse<CreateOrderResponse>> createOrder(CreateOrderRequest request);
  Future<BaseResponse<UserOrderResponse>> getUserOrders();
}