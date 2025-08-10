import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  static const String _accessTokenKey = 'access_token';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip adding token for auth endpoints that don't need authentication
    if (options.path.contains('/api/Auth/Login') || 
        options.path.contains('/api/Auth/Register') ||
        options.path.contains('/api/Auth/SendOTP') ||
        options.path.contains('/api/Auth/VerifyUser')) {
      print('🔐 AuthInterceptor: Skipping token for public auth endpoint: ${options.path}');
      handler.next(options);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(_accessTokenKey);
      
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        print('🔐 AuthInterceptor: Added token to ${options.path}');
        print('🔐 AuthInterceptor: Token preview: ${accessToken.substring(0, 20)}...');
      } else {
        print('⚠️ AuthInterceptor: No token found for ${options.path}');
      }
    } catch (e) {
      // If there's an error getting the token, continue without it
      print('❌ AuthInterceptor: Error getting access token: $e');
    }
    
    handler.next(options);
  }
}
