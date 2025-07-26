import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/creating_elder_request.dart';
import 'package:silvercart/models/login_response.dart';
import 'package:silvercart/network/data/auth_api_service.dart';
import 'package:silvercart/network/repositories/auth/auth_repository.dart';

@LazySingleton(as: AuthRepository, env: [Environment.prod])
class AuthRepositoryApi implements AuthRepository {
  AuthApiService _api;
  AuthRepositoryApi(this._api);
  @override
  Future<BaseResponse<LoginResponse>> signIn(String email, String password) async {
    try {
    final response = await _api.signIn({'email': email, 'password': password});
      return BaseResponse.success(data: response);
    } catch (e) {
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
    required String gender,
    required Map<String, dynamic> address,
    required bool isGuardian,
  }) async {
    await _api.register({
      'email': email,
      'password': password,
      'phone': phone,
      'fullName': fullName,
      'gender': gender,
      'address': address,
      'isGuardian': isGuardian,
    });
  }

  @override
  Future<BaseResponse<void>> registerDependentUser(CreatingElderRequest request) async {
    try {
      await _api.registerDependentUser(request.toJson());
      return BaseResponse.success(data: null);
    } catch (e) {
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<void>> changePassword(String oldPassword, String newPassword) async {
    try {
      await _api.changePassword({'oldPassword': oldPassword, 'newPassword': newPassword});
      return BaseResponse.success(data: null);
    } catch (e) {
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<String>> generateQrLoginToken(String value) async {
    try {
      await _api.generateQrLoginToken(value);
      return BaseResponse.success(data: '123');
    } catch (e) {
      return BaseResponse.error(message: e.toString());
    }
  }
}