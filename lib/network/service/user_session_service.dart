import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton()
class UserSessionService {
  // User session keys
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _rememberMeKey = 'remember_me';
  static const String _lastLoginEmailKey = 'last_login_email';
  static const String _appVersionKey = 'app_version';

  // Check if this is the first app launch
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  // Mark app as launched
  Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLaunchKey, false);
  }

  // Remember me functionality
  Future<void> setRememberMe(bool remember, {String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, remember);
    
    if (remember && email != null) {
      await prefs.setString(_lastLoginEmailKey, email);
    } else {
      await prefs.remove(_lastLoginEmailKey);
    }
  }

  Future<bool> shouldRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<String?> getLastLoginEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastLoginEmailKey);
  }

  // App version tracking
  Future<void> setAppVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appVersionKey, version);
  }

  Future<String?> getAppVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_appVersionKey);
  }

  // Clear all session data
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_lastLoginEmailKey);
  }

  // Get all session info for debugging
  Future<Map<String, dynamic>> getSessionInfo() async {
    return {
      'isFirstLaunch': await isFirstLaunch(),
      'rememberMe': await shouldRememberMe(),
      'lastLoginEmail': await getLastLoginEmail(),
      'appVersion': await getAppVersion(),
    };
  }
} 