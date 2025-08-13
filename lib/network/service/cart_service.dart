import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/cart_replace_request.dart';
import 'package:silvercart/models/cart_replace_response.dart';
import 'package:silvercart/models/cart_get_response.dart';
import 'package:silvercart/models/change_cart_status_response.dart';
import 'package:silvercart/models/elder_carts_response.dart';
import 'package:silvercart/network/repositories/cart/cart_repository.dart';

class CartService {
  final CartRepository _repo;

  CartService(this._repo);

  Future<BaseResponse<CartReplaceResponse>> replaceAllCart(CartReplaceRequest request) async {
    return await _repo.replaceAllCart(request);
  }

  Future<BaseResponse<CartGetResponse>> getCartByCustomerId(String customerId, int status) async {
    return await _repo.getCartByCustomerId(customerId, status);
  }

  Future<BaseResponse<CartGetResponse>> getCartByElderId(String elderId, int status) async {
    return await _repo.getCartByElderId(elderId, status);
  }

  Future<BaseResponse<ChangeCartStatusResponse>> changeCartStatus(String cartId, int status) async {
    return await _repo.changeCartStatus(cartId, status);
  }

  Future<BaseResponse<ElderCartsResponse>> getAllElderCarts() async {
    return await _repo.getAllElderCarts();
  }
}
