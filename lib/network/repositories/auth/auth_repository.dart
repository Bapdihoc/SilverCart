import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/creating_elder_request.dart';
import 'package:silvercart/models/login_response.dart';
import 'package:silvercart/models/user_detail_response.dart';
import 'package:silvercart/models/user_me_response.dart';
import 'package:silvercart/models/qr_generate_response.dart';

abstract class AuthRepository {
  Future<BaseResponse<LoginResponse>> signIn(String email, String password);
  // Future<void> signUp(String email, String password);
  Future<void> signOut();
  Future<void> signUp({
    required String email,
    required String password,
    required String phone,
    required String fullName,
  });
  Future<BaseResponse<void>> registerDependentUser(CreatingElderRequest request);
  Future<BaseResponse<void>> changePassword(String oldPassword, String newPassword);
  Future<BaseResponse<QrGenerateResponse>> generateQr(String userId);
  Future<BaseResponse<void>> sendOTP(String emailOrPhone);
  Future<BaseResponse<void>> verifyOTP(String otpCode);
  Future<BaseResponse<UserDetailResponse>> getUserDetail(String id);
  Future<BaseResponse<UserMeResponse>> getMe();
}