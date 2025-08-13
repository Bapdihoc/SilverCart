import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/creating_elder_request.dart';
import 'package:silvercart/models/login_response.dart';
import 'package:silvercart/models/user_detail_response.dart';
import 'package:silvercart/models/user_me_response.dart';
import 'package:silvercart/models/qr_generate_response.dart';
import 'package:silvercart/network/repositories/auth/auth_repository.dart';

@LazySingleton()
class AuthService {
  final AuthRepository _repo;
  AuthService(this._repo);

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _expirationKey = 'token_expiration';

  Future<BaseResponse<LoginResponse>> signIn(String email, String password) async {
    final result = await _repo.signIn(email, password);
    
    // If login successful, save tokens and user data
    if (result.isSuccess && result.data != null) {
      await _saveLoginData(result.data!);
    }
    
    return result;
  }

  
  Future<void> signOut() async {
    await _repo.signOut();
    await _clearLoginData();
  }

  Future<void> register({
    required String email,
    required String password,
    required String phone,
    required String fullName,
  }) async {
    await _repo.signUp(
      email: email,
      password: password,
      phone: phone,
      fullName: fullName,
    );
  }

  Future<BaseResponse<void>> registerDependentUser(CreatingElderRequest request) async {
    return await _repo.registerDependentUser(request);
  }

  Future<BaseResponse<void>> changePassword(String oldPassword, String newPassword) async {
    return await _repo.changePassword(oldPassword, newPassword);
  }

  Future<BaseResponse<QrGenerateResponse>> generateQr(String userId) async {
    return await _repo.generateQr(userId);
  }

  Future<BaseResponse<void>> sendOTP(String emailOrPhone) async {
    return await _repo.sendOTP(emailOrPhone);
  }

  Future<BaseResponse<void>> verifyOTP(String otpCode) async {
    return await _repo.verifyOTP(otpCode);
  }

  Future<BaseResponse<UserDetailResponse>> getUserDetail(String id) async {
    return await _repo.getUserDetail(id);
  }

  Future<BaseResponse<UserMeResponse>> getMe() async {
    return await _repo.getMe();
  }

  // Validate token by calling /api/Auth/Me with the provided token
  Future<BaseResponse<UserMeResponse>> validateToken(String token) async {
    // Temporarily save the token to validate it
    final prefs = await SharedPreferences.getInstance();
    final originalToken = prefs.getString(_accessTokenKey);
    
    try {
      // Set the token temporarily
      await prefs.setString(_accessTokenKey, token);
      
      // Try to call /api/Auth/Me to validate the token
      final result = await _repo.getMe();
      
      if (result.isSuccess && result.data != null) {
        // Token is valid, keep it and save user data
        final userData = result.data!;
        await prefs.setString(_userIdKey, userData.userId ?? '');
        await prefs.setString(_userRoleKey, userData.role ?? '');
        await prefs.setString("userId", userData.userId ?? '');
        // Set a default expiration (e.g., 24 hours from now)
        final expiration = DateTime.now().add(Duration(hours: 24));
        await prefs.setString(_expirationKey, expiration.toIso8601String());
        
        print('🔑 AuthService: Token validated successfully');
        print('🔑 AuthService: User ID: ${userData.userId}');
        print('🔑 AuthService: Role: ${userData.role}');
      } else {
        // Token is invalid, restore original token
        if (originalToken != null) {
          await prefs.setString(_accessTokenKey, originalToken);
        } else {
          await prefs.remove(_accessTokenKey);
        }
      }
      
      return result;
    } catch (e) {
      // Restore original token on error
      if (originalToken != null) {
        await prefs.setString(_accessTokenKey, originalToken);
      } else {
        await prefs.remove(_accessTokenKey);
      }
      
      return BaseResponse.error(message: 'Token validation failed: ${e.toString()}');
    }
  }
  // Save login data to SharedPreferences
  Future<void> _saveLoginData(LoginResponse loginData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, loginData.data); // JWT token
    await prefs.setString(_userIdKey, loginData.getUserId() ?? '');
    await prefs.setString(_userRoleKey, loginData.getRole() ?? '');
    await prefs.setString(_expirationKey, loginData.getExpiration()?.toIso8601String() ?? '');
    
    // Debug logging
    print('💾 AuthService: Token saved successfully');
    print('💾 AuthService: Token preview: ${loginData.data.substring(0, 20)}...');
    print('💾 AuthService: User ID: ${loginData.getUserId()}');
    print('💾 AuthService: Role: ${loginData.getRole()}');
    print('💾 AuthService: Expiration: ${loginData.getExpiration()}');
  }

  // Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }



  // Get user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get user role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    if (token == null) return false;

    // Check if token is expired
    final prefs = await SharedPreferences.getInstance();
    final expirationString = prefs.getString(_expirationKey);
    if (expirationString == null) return false;

    final expiration = DateTime.parse(expirationString);
    return DateTime.now().isBefore(expiration);
  }

  // Clear login data
  Future<void> _clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_expirationKey);
  }

  // Get current user data
  Future<Map<String, String?>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'role': prefs.getString(_userRoleKey),
      'accessToken': prefs.getString(_accessTokenKey),
    };
  }

  // Check if token needs refresh (expires in next 5 minutes)
  Future<bool> shouldRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final expirationString = prefs.getString(_expirationKey);
    if (expirationString == null) return false;

    final expiration = DateTime.parse(expirationString);
    final fiveMinutesFromNow = DateTime.now().add(Duration(minutes: 5));
    return expiration.isBefore(fiveMinutesFromNow);
  }
}