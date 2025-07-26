import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/creating_elder_request.dart';
import 'package:silvercart/models/order_response.dart';
import 'package:silvercart/network/repositories/order/order_respository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: OrderRespository, env: [Environment.dev])
class OrderRespositoryMock implements OrderRespository {
  @override
  Future<BaseResponse<OrderResponse>> getOrders() async {
    return BaseResponse.success(data: OrderResponse(pageNumber: 1, pageSize: 10, totalNumberOfPages: 1, totalNumberOfRecords: 10, results: []));
  }

  @override
  Future<BaseResponse<OrderResponse>> getOrder(int id) async {
        return BaseResponse.success(data: OrderResponse(pageNumber: 1, pageSize: 10, totalNumberOfPages: 1, totalNumberOfRecords: 10, results: []));
  }

  // @override
  // Future<BaseResponse<Order>> createOrder() async {
  //   return BaseResponse.success(data: Order(id: '1', totalPrice: 100, creationDate: DateTime.now(), orderStatus: OrderStatus.PENDING, address: '1', orderDetails: []));
  // }
  
}