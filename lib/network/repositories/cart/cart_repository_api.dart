import 'package:dio/dio.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/cart_replace_request.dart';
import 'package:silvercart/models/cart_replace_response.dart';
import 'package:silvercart/models/cart_get_response.dart';
import 'package:silvercart/models/change_cart_status_response.dart';
import 'package:silvercart/models/elder_carts_response.dart';
import 'package:silvercart/network/data/cart_api_service.dart';
import 'package:silvercart/network/data/api_response_handler.dart';
import 'package:silvercart/network/repositories/cart/cart_repository.dart';

class CartRepositoryApi implements CartRepository {
  final CartApiService _api;

  CartRepositoryApi(this._api);

  @override
  Future<BaseResponse<CartReplaceResponse>> replaceAllCart(CartReplaceRequest request) async {
    try {
      final response = await _api.replaceAllCart(request);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<CartReplaceResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<CartGetResponse>> getCartByCustomerId(String customerId, int status) async {
    try {
      final response = await _api.getCartByCustomerId(customerId, status);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<CartGetResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<CartGetResponse>> getCartByElderId(String elderId, int status) async {
    try {
      final response = await _api.getCartByElderId(elderId, status);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<CartGetResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<ChangeCartStatusResponse>> changeCartStatus(String cartId, int status) async {
    try {
      final response = await _api.changeCartStatus(cartId, status);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<ChangeCartStatusResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<ElderCartsResponse>> getAllElderCarts() async {
    try {
      final response = await _api.getAllElderCarts();
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<ElderCartsResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }
}
