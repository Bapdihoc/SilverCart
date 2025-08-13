import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/creating_elder_request.dart';
import 'package:silvercart/models/login_response.dart';
import 'package:silvercart/models/user_detail_response.dart';
import 'package:silvercart/models/user_me_response.dart';
import 'package:silvercart/models/qr_generate_response.dart';
import 'package:silvercart/network/repositories/auth/auth_repository.dart';

@LazySingleton(as: AuthRepository, env: [Environment.dev])
class AuthRepositoryMock implements AuthRepository {
  @override
  Future<BaseResponse<LoginResponse>> signIn(String email, String password) async {
    return BaseResponse.success(data: LoginResponse(
      message: 'Login successfully',
      data: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VyTmFtZSI6InRyaWN1b25nODYzNS53b3JrQGdtYWlsLmNvbSIsIlVzZXJJZCI6IjZmOGVlNGUzLWIwMGEtNDdmNy1iMDZhLTI3OGFhYTVhZjk2NyIsIlJvbGUiOiJHdWFyZGlhbiIsImV4cCI6MTc1NDU4NDI1NCwiaXNzIjoiWW91ckFwcE5hbWUiLCJhdWQiOiJZb3VyQXBwQXVkaWVuY2UifQ.5Tq5XbDLFmF9AsUtkVWO4u63EtOnAjplL6gWBtkKiSw',
    ));
  }
  
  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String phone,
    required String fullName,
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

  @override
  Future<BaseResponse<void>> sendOTP(String emailOrPhone) async {
    return BaseResponse.success(data: null);
  }

  @override
  Future<BaseResponse<void>> verifyOTP(String otpCode) async {
    return BaseResponse.success(data: null);
  }

  @override
  Future<BaseResponse<UserDetailResponse>> getUserDetail(String id) async {
    return BaseResponse.success(data: UserDetailResponse(
      message: 'Get user detail successfully',
      data: UserDetailData(
        id: id,
        fullName: 'Nguyễn Văn A',
        userName: 'Nguyễn Văn A',
        email: null,
        avatar: null,
        gender: 1,
        phoneNumber: null,
        birthDate: DateTime(1950, 1, 1),
        age: 75,
        rewardPoint: 0,
        description: 'Bệnh tiểu đường',
        relationShip: 'Ông',
        guardianId: '6f8ee4e3-b00a-47f7-b06a-278aaa5af967',
        roleId: '22222222-2222-2222-2222-222222222222',
        roleName: 'Elder',
        addresses: [
          UserDetailAddress(
            id: '27102bc9-bfdb-4721-36e0-08ddd7195ef9',
            streetAddress: '123 Đường ABC',
            wardCode: '541305',
            wardName: 'Phường ABC',
            districtID: 2111,
            districtName: 'Quận XYZ',
            provinceID: 206,
            provinceName: 'Hồ Chí Minh',
            phoneNumber: '0967676722',
          ),
        ],
        categoryValues: [
          UserCategoryValue(
            id: '2b2d5572-8327-4dee-7c95-08ddd50b5c9b',
            code: 'health_care',
            description: 'Các sản phẩm và dịch vụ chăm sóc sức khỏe cho người cao tuổi',
            label: 'Chăm sóc sức khỏe',
            type: 0,
            childrenId: 'bcf673f9-38e1-4fc1-80b3-08ddd50b9acd',
            childrentLabel: null,
          ),
        ],
      ),
    ));
  }

  @override
  Future<BaseResponse<UserMeResponse>> getMe() async {
    return BaseResponse.success(data: UserMeResponse(
      userId: '6f8ee4e3-b00a-47f7-b06a-278aaa5af967',
      userName: 'tricuong8635.work@gmail.com',
      role: 'Guardian',
    ));
  }

  @override
  Future<BaseResponse<QrGenerateResponse>> generateQr(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    return BaseResponse.success(data: QrGenerateResponse(
      message: 'QR code generated successfully',
      data: QrGenerateData(
        token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VyTmFtZSI6Im5nIHRoYW4gMiIsIlVzZXJJZCI6ImVlMDQ2NzMwLWY2N2QtNDQ3ZC1hNWE2LTFkZmI4MGFlOGNiNyIsIlJvbGUiOiIiLCJleHAiOjE3NTQ4MjI0NjIsImlzcyI6IllvdXJBcHBOYW1lIiwiYXVkIjoiWW91ckFwcEF1ZGllbmNlIn0.38qGDqLann-l6AqG70wxYrdhFFmLvRzVffSBRD9vIPU',
      ),
    ));
  }
}