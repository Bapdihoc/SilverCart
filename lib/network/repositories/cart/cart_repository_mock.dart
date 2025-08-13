import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/cart_replace_request.dart';
import 'package:silvercart/models/cart_replace_response.dart';
import 'package:silvercart/models/cart_get_response.dart';
import 'package:silvercart/models/change_cart_status_response.dart';
import 'package:silvercart/models/elder_carts_response.dart';
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

  @override
  Future<BaseResponse<CartGetResponse>> getCartByElderId(String elderId, int status) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    return BaseResponse.success(data: CartGetResponse(
      message: 'Get cart successfully',
      data: CartGetData(
        cartId: '762e7e0f-8708-4058-9853-08ddd7e59fd7',
        customerId: '762e7e0f-8708-4058-9853-08ddd7e59fd7',
        customerName: 'Elderly User',
        elderId: elderId,
        elderName: 'Bà Nguyễn Thị A',
        status: 'Created',
        items: [
          CartGetItem(
            productVariantId: 'b2200519-4f22-4f0a-2b37-08ddd50d48f2',
            productName: 'Thuốc bổ tim mạch cho người cao tuổi',
            quantity: 1,
            productPrice: 250000,
            imageUrl: null,
          ),
          CartGetItem(
            productVariantId: 'c3300519-4f22-4f0a-2b37-08ddd50d48f3',
            productName: 'Máy đo huyết áp cổ tay Omron',
            quantity: 1,
            productPrice: 850000,
            imageUrl: null,
          ),
          CartGetItem(
            productVariantId: 'd4400519-4f22-4f0a-2b37-08ddd50d48f4',
            productName: 'Vitamin tổng hợp Senior',
            quantity: 2,
            productPrice: 180000,
            imageUrl: null,
          ),
        ],
      ),
    ));
  }

  @override
  Future<BaseResponse<ChangeCartStatusResponse>> changeCartStatus(String cartId, int status) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    return BaseResponse.success(data: ChangeCartStatusResponse(
      message: 'Success',
      data: null,
    ));
  }

  @override
  Future<BaseResponse<ElderCartsResponse>> getAllElderCarts() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1200));
    
    return BaseResponse.success(data: ElderCartsResponse(
      message: 'Elder carts retrieved successfully.',
      data: [
        ElderCartData(
          cartId: 'd6179cfe-baa6-442b-f2ca-08ddd90909c5',
          customerId: '6f8ee4e3-b00a-47f7-b06a-278aaa5af967',
          customerName: 'NGUYEN VAN C',
          elderId: 'ee046730-f67d-447d-a5a6-1dfb80ae8cb7',
          elderName: 'Bà Nguyễn Thị Lan',
          status: 'Pending',
          items: [
            ElderCartItem(
              productVariantId: 'a1100519-4f22-4f0a-2b37-08ddd50d48f1',
              productName: 'Gậy chống cao cấp Drive Medical',
              quantity: 1,
              productPrice: 350000,
              imageUrl: null,
              discount: 0,
            ),
            ElderCartItem(
              productVariantId: 'b2200519-4f22-4f0a-2b37-08ddd50d48f2',
              productName: 'Thuốc huyết áp Amlodipine',
              quantity: 2,
              productPrice: 75000,
              imageUrl: null,
              discount: 0,
            ),
          ],
        ),
        ElderCartData(
          cartId: 'c5289cfe-baa6-442b-f2ca-08ddd90909c6',
          customerId: '7f9ee4e3-b00a-47f7-b06a-278aaa5af968',
          customerName: 'TRAN THI B',
          elderId: 'fe046730-f67d-447d-a5a6-1dfb80ae8cb8',
          elderName: 'Ông Trần Văn Minh',
          status: 'Created',
          items: [
            ElderCartItem(
              productVariantId: 'c3300519-4f22-4f0a-2b37-08ddd50d48f3',
              productName: 'Sữa Ensure Gold Vanilla',
              quantity: 3,
              productPrice: 180000,
              imageUrl: null,
              discount: 10000,
            ),
          ],
        ),
        ElderCartData(
          cartId: 'a4189cfe-baa6-442b-f2ca-08ddd90909c7',
          customerId: '8f8ee4e3-b00a-47f7-b06a-278aaa5af969',
          customerName: 'LE VAN D',
          elderId: 'df046730-f67d-447d-a5a6-1dfb80ae8cb9',
          elderName: 'Bà Lê Thị Thu',
          status: 'Approve',
          items: [
            ElderCartItem(
              productVariantId: 'd4400519-4f22-4f0a-2b37-08ddd50d48f4',
              productName: 'Vitamin tổng hợp Senior',
              quantity: 1,
              productPrice: 250000,
              imageUrl: null,
              discount: 0,
            ),
            ElderCartItem(
              productVariantId: 'e5500519-4f22-4f0a-2b37-08ddd50d48f5',
              productName: 'Máy đo huyết áp cổ tay',
              quantity: 1,
              productPrice: 850000,
              imageUrl: null,
              discount: 50000,
            ),
          ],
        ),
      ],
    ));
  }
}
