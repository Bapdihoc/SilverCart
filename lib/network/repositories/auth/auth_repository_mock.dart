import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/creating_elder_request.dart';
import 'package:silvercart/models/login_response.dart';
import 'package:silvercart/network/repositories/auth/auth_repository.dart';

@LazySingleton(as: AuthRepository, env: [Environment.dev])
class AuthRepositoryMock implements AuthRepository {
  @override
  Future<BaseResponse<LoginResponse>> signIn(String email, String password) async {
    return BaseResponse.success(data: LoginResponse(
      userId: '1',
      role: 'admin',
      accessToken: '123',
      refreshToken: '123',
      expiration: DateTime.now(),
    ));
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
    // TODO: Implement signUp
  }
  
  @override
  Future<void> signOut() async {
    // TODO: Implement signOut
  }

  @override
  Future<BaseResponse<void>> registerDependentUser(CreatingElderRequest request) async {
    return BaseResponse.success(data: null);
  }

  @override
  Future<BaseResponse<void>> changePassword(String oldPassword, String newPassword) async {
    return BaseResponse.success(data: null);
  }

  @override
  Future<BaseResponse<String>> generateQrLoginToken(String value) async {
    return BaseResponse.success(data: '123');
  }
}