import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/creating_elder_request.dart';
import 'package:silvercart/models/login_response.dart';
import 'package:silvercart/network/repositories/auth/auth_repository.dart';

@LazySingleton()
class AuthService {
  final AuthRepository _repo;
  AuthService(this._repo);

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
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
    required String gender,
    required Map<String, dynamic> address,
    required bool isGuardian,
  }) async {
    await _repo.signUp(
      email: email,
      password: password,
      phone: phone,
      fullName: fullName,
      gender: gender,
      address: address,
      isGuardian: isGuardian,
    );
  }

  Future<BaseResponse<void>> registerDependentUser(CreatingElderRequest request) async {
    return await _repo.registerDependentUser(request);
  }

  Future<BaseResponse<void>> changePassword(String oldPassword, String newPassword) async {
    return await _repo.changePassword(oldPassword, newPassword);
  }

  Future<BaseResponse<String>> generateQrLoginToken(String value) async {
    return await _repo.generateQrLoginToken(value);
  }
  // Save login data to SharedPreferences
  Future<void> _saveLoginData(LoginResponse loginData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, loginData.accessToken);
    await prefs.setString(_refreshTokenKey, loginData.refreshToken);
    await prefs.setString(_userIdKey, loginData.userId);
    await prefs.setString(_userRoleKey, loginData.role);
    await prefs.setString(_expirationKey, loginData.expiration.toIso8601String());
  }

  // Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
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
    await prefs.remove(_refreshTokenKey);
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
      'refreshToken': prefs.getString(_refreshTokenKey),
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