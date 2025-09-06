import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'error_interceptor.dart';
import 'auth_interceptor.dart';
import 'category_api_service.dart';
import 'promotion_api_service.dart';
import 'payment_history_api_service.dart';
import 'report_api_service.dart';

@module
abstract class DioModule {
  @LazySingleton()
  Dio provideDio() {
    final dio = Dio();
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl != null) {
      dio.options.baseUrl = baseUrl;
    }
    
    // Add auth interceptor first (to add token to all requests)
    dio.interceptors.add(AuthInterceptor());
    
    // Add error interceptor (to handle errors before logging)
    dio.interceptors.add(ErrorInterceptor());
    
    // Add logging interceptor for development
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (object) {
        log(jsonEncode(object));
      },
    ));
    
                    dio.options.headers['Content-Type'] = 'application/json';
                dio.options.headers['Accept'] = '*/*';
    
    return dio;
  }

  @LazySingleton()
  CategoryApiService provideCategoryApiService(Dio dio) => CategoryApiService(dio);

  @LazySingleton()
  PromotionApiService providePromotionApiService(Dio dio) => PromotionApiService(dio);

  @LazySingleton()
  PaymentHistoryApiService providePaymentHistoryApiService(Dio dio) => PaymentHistoryApiService(dio);

  @LazySingleton()
  ReportApiService provideReportApiService(Dio dio) => ReportApiService(dio);
} 