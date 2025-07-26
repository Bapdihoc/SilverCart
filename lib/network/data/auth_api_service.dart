import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:silvercart/models/login_response.dart';
part 'auth_api_service.g.dart';

class ParseErrorLogger {
  const ParseErrorLogger();
  void logError(Object error, StackTrace stackTrace, dynamic options) {
    // You can implement logging here, or leave it empty for now
  }
}

@module
abstract class AuthApiModule {
  @LazySingleton()
  AuthApiService provideAuthApiService(Dio dio) {
    final baseUrl = dotenv.env['BASE_URL'];
    return AuthApiService(dio, baseUrl: baseUrl);
  }
}

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String? baseUrl}) = _AuthApiService;

  @POST('/api/Auth/login')
  Future<LoginResponse> signIn( @Body() Map<String, dynamic> queryParams);

  @POST('/users')
  Future<void> signUp( @Queries() Map<String, dynamic> queryParams);

  @POST('/users/logout')
  Future<void> signOut();

  @POST('/api/Auth/register')
  Future<void> register(@Body() Map<String, dynamic> body);

  @POST('/api/Auth/register/dependent-user')
  Future<void> registerDependentUser(@Body() Map<String, dynamic> body);
  
  @POST('/api/Auth/change-password')
  Future<void> changePassword(@Body() Map<String, dynamic> body);

  @GET('api/Auth/generate-qr-login-token')
  Future<void> generateQrLoginToken(@Query('dependentUserId') String dependentUserId);
}