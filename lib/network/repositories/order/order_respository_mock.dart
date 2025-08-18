import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/creating_elder_request.dart';
import 'package:silvercart/models/order_response.dart';
import 'package:silvercart/models/create_order_request.dart';
import 'package:silvercart/models/create_order_response.dart';
import 'package:silvercart/models/user_order_response.dart';
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

  @override
  Future<BaseResponse<CreateOrderResponse>> createOrder(CreateOrderRequest request) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    // Return mock payment link in data field
    return BaseResponse.success(
      data: CreateOrderResponse(
        message: 'Create VNPAY order (mock)',
        data: 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?mock=true',
      ),
    );
  }

  @override
  Future<BaseResponse<UserOrderResponse>> getUserOrders() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock data with sample orders
    return BaseResponse.success(
      data: UserOrderResponse(
        message: 'Get order successfully',
        data: [
          UserOrderData(
            id: 'f7fb58f5-9bcf-4ea2-3a08-08ddd9041d9f',
            totalPrice: 1560000,
            note: 'Giao hàng nhanh',
            orderStatus: 1, // Paid
            elderName: 'Bà Nguyễn Thị A',
            orderDetails: [
              UserOrderDetail(
                productName: 'Gậy chống cao cấp Drive Medical',
                price: 350000,
                quantity: 3,
              ),
              UserOrderDetail(
                productName: 'Gậy chống cao cấp Drive Medical',
                price: 360000,
                quantity: 1,
              ),
              UserOrderDetail(
                productName: 'Máy đo huyết áp cổ tay Omron HEM-6161',
                price: 850000,
                quantity: 1,
              ),
            ],
          ),
          UserOrderData(
            id: 'a8fc58f5-9bcf-4ea2-3b09-08ddd9041d9g',
            totalPrice: 650000,
            note: '',
            orderStatus: 2, // Shipping
            elderName: 'Ông Trần Văn B',
            orderDetails: [
              UserOrderDetail(
                productName: 'Thuốc bổ tim mạch',
                price: 250000,
                quantity: 2,
              ),
              UserOrderDetail(
                productName: 'Vitamin tổng hợp cho người cao tuổi',
                price: 150000,
                quantity: 1,
              ),
            ],
          ),
          UserOrderData(
            id: 'b9fd58f5-9bcf-4ea2-3c10-08ddd9041d9h',
            totalPrice: 320000,
            note: 'Để ngoài cửa',
            orderStatus: 3, // Completed
            elderName: 'Bà Lê Thị C',
            orderDetails: [
              UserOrderDetail(
                productName: 'Dầu gội dành cho người cao tuổi',
                price: 120000,
                quantity: 2,
              ),
              UserOrderDetail(
                productName: 'Kem dưỡng da chống lão hóa',
                price: 80000,
                quantity: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}