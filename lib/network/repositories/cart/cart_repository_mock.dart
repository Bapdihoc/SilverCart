import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/cart_replace_request.dart';
import 'package:silvercart/models/cart_replace_response.dart';
import 'package:silvercart/models/cart_get_response.dart';
import 'package:silvercart/network/repositories/cart/cart_repository.dart';

class CartRepositoryMock implements CartRepository {
  @override
  Future<BaseResponse<CartReplaceResponse>> replaceAllCart(CartReplaceRequest request) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    return BaseResponse.success(data: CartReplaceResponse(
      message: 'Cart updated successfully',
      data: null,
    ));
  }

  @override
  Future<BaseResponse<CartGetResponse>> getCartByCustomerId(String customerId, int status) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    return BaseResponse.success(data: CartGetResponse(
      message: 'Get cart successfully',
      data: CartGetData(
        cartId: '862e7e0f-8708-4058-9853-08ddd7e59fd6',
        customerId: customerId,
        customerName: 'NGUYEN VAN C',
        elderId: '862e7e0f-8708-4058-9853-08ddd7e59fd6',
        elderName: null,
        status: 'Created',
        items: [
          CartGetItem(
            productVariantId: 'a1100519-4f22-4f0a-2b37-08ddd50d48f1',
            productName: 'Gậy chống cao cấp Drive Medical',
            quantity: 2,
            productPrice: 350000,
            imageUrl: 'https://example.com/images/gay-chong-den.jpg',
          ),
          CartGetItem(
            productVariantId: '665c726b-e9f7-4e5b-2b38-08ddd50d48f1',
            productName: 'Gậy chống cao cấp Drive Medical',
            quantity: 3,
            productPrice: 360000,
            imageUrl: null,
          ),
        ],
      ),
    ));
  }
}
