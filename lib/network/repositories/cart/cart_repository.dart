import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/cart_replace_request.dart';
import 'package:silvercart/models/cart_replace_response.dart';
import 'package:silvercart/models/cart_get_response.dart';
import 'package:silvercart/models/change_cart_status_response.dart';
import 'package:silvercart/models/elder_carts_response.dart';

abstract class CartRepository {
  Future<BaseResponse<CartReplaceResponse>> replaceAllCart(CartReplaceRequest request);
  Future<BaseResponse<CartGetResponse>> getCartByCustomerId(String customerId, int status);
  Future<BaseResponse<CartGetResponse>> getCartByElderId(String elderId, int status);
  Future<BaseResponse<ChangeCartStatusResponse>> changeCartStatus(String cartId, int status);
  Future<BaseResponse<ElderCartsResponse>> getAllElderCarts();
}
