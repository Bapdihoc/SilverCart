import '../../../injection.dart';
import '../../network/service/auth_service.dart';
import '../../network/service/user_session_service.dart';

/// Utility class for easy access to authentication data
class AuthUtils {
  static AuthService get _authService => getIt<AuthService>();
  static UserSessionService get _sessionService => getIt<UserSessionService>();

  /// Check if user is currently logged in
  static Future<bool> isLoggedIn() => _authService.isLoggedIn();

  /// Get current user access token
  static Future<String?> getAccessToken() => _authService.getAccessToken();

  /// Get current user refresh token  
  // static Future<String?> getRefreshToken() => _authService.getRefreshToken();

  /// Get current user ID
  static Future<String?> getUserId() => _authService.getUserId();

  /// Get current user role
  static Future<String?> getUserRole() => _authService.getUserRole();

  /// Get all current user data
  static Future<Map<String, String?>> getCurrentUser() => _authService.getCurrentUser();

  /// Check if token should be refreshed
  static Future<bool> shouldRefreshToken() => _authService.shouldRefreshToken();

  /// Sign out user and clear all data
  static Future<void> signOut() async {
    await _authService.signOut();
    await _sessionService.clearSession();
  }

  /// Get session info
  static Future<Map<String, dynamic>> getSessionInfo() => _sessionService.getSessionInfo();

  /// Check if this is first app launch
  static Future<bool> isFirstLaunch() => _sessionService.isFirstLaunch();

  /// Mark first launch as completed
  static Future<void> setFirstLaunchCompleted() => _sessionService.setFirstLaunchCompleted();

  /// Set remember me with optional email
  static Future<void> setRememberMe(bool remember, {String? email}) =>
      _sessionService.setRememberMe(remember, email: email);

  /// Check if should remember user
  static Future<bool> shouldRememberMe() => _sessionService.shouldRememberMe();

  /// Get last login email
  static Future<String?> getLastLoginEmail() => _sessionService.getLastLoginEmail();

  /// Debug: Print all auth and session data
  static Future<void> debugPrintAuthData() async {
    final userData = await getCurrentUser();
    final sessionData = await getSessionInfo();
    final isLoggedIn = await AuthUtils.isLoggedIn();
    
    print('=== AUTH DEBUG INFO ===');
    print('Is Logged In: $isLoggedIn');
    print('User Data: $userData');
    print('Session Data: $sessionData');
    print('=======================');
  }
} 