import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/cart_replace_request.dart';
import 'package:silvercart/models/cart_replace_response.dart';
import 'package:silvercart/models/cart_get_response.dart';
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
}
