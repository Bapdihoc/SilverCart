import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/creating_elder_request.dart';
import 'package:silvercart/models/login_response.dart';
import 'package:silvercart/models/user_detail_response.dart';
import 'package:silvercart/models/user_me_response.dart';
import 'package:silvercart/models/qr_generate_response.dart';
import 'package:silvercart/network/data/auth_api_service.dart';
import 'package:silvercart/network/data/api_response_handler.dart';
import 'package:silvercart/network/repositories/auth/auth_repository.dart';

@LazySingleton(as: AuthRepository, env: [Environment.prod])
class AuthRepositoryApi implements AuthRepository {
  AuthApiService _api;
  AuthRepositoryApi(this._api);
  @override
  Future<BaseResponse<LoginResponse>> signIn(String email, String password) async {
    try {
      final response = await _api.signIn({
        'userName': email,
        'password': password,
      });
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<LoginResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }
  

  @override
  Future<void> signOut() async {
    // TODO: Implement signOut
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String phone,
    required String fullName,
  }) async {
    try {
      await _api.register({
        'fullName': fullName,
        'email': email,
        'password': password,
        'phoneNumber': phone,
        'userName': email, // username and email have the same value
      });
    } catch (e) {
      if (e is DioException) {
        final errorResponse = ApiResponseHandler.handleError<void>(e);
        throw Exception(errorResponse.message);
      }
      throw e;
    }
  }

  @override
  Future<BaseResponse<void>> registerDependentUser(CreatingElderRequest request) async {
    try {
      await _api.registerDependentUser(request.toJson());
      return BaseResponse.success(data: null);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<void>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<void>> changePassword(String oldPassword, String newPassword) async {
    try {
      await _api.changePassword({'oldPassword': oldPassword, 'newPassword': newPassword});
      return BaseResponse.success(data: null);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<void>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }



  @override
  Future<BaseResponse<void>> sendOTP(String emailOrPhone) async {
    try {
      await _api.sendOTP({'emailOrPhone': emailOrPhone});
      return BaseResponse.success(data: null);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<void>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<void>> verifyOTP(String otpCode) async {
    try {
      await _api.verifyOTP(otpCode);
      return BaseResponse.success(data: null);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<void>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<UserDetailResponse>> getUserDetail(String id) async {
    try {
      final response = await _api.getUserDetail(id);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<UserDetailResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<UserMeResponse>> getMe() async {
    try {
      final response = await _api.getMe();
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<UserMeResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<QrGenerateResponse>> generateQr(String userId) async {
    try {
      final response = await _api.generateQr({
        'elderId': userId,
      });
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<QrGenerateResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }
}