import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioModule {
  @LazySingleton()
  Dio provideDio() {
    final dio = Dio();
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl != null) {
      dio.options.baseUrl = baseUrl;
    }
    
    // Add logging interceptor for development
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
    
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    
    return dio;
  }
} 