import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/creating_elder_request.dart';
import 'package:silvercart/models/login_response.dart';

abstract class AuthRepository {
  Future<BaseResponse<LoginResponse>> signIn(String email, String password);
  // Future<void> signUp(String email, String password);
  Future<void> signOut();
  Future<void> signUp({
    required String email,
    required String password,
    required String phone,
    required String fullName,
    required String gender,
    required Map<String, dynamic> address,
    required bool isGuardian,
  });
  Future<BaseResponse<void>> registerDependentUser(CreatingElderRequest request);
  Future<BaseResponse<void>> changePassword(String oldPassword, String newPassword);
  Future<BaseResponse<String>> generateQrLoginToken(String value);
}