import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:dio/dio.dart' show Response;
import 'package:injectable/injectable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:silvercart/models/elder_request.dart';
import 'package:silvercart/models/elder_response.dart';
import 'package:silvercart/models/elder_list_response.dart';

part 'elder_api_service.g.dart';

class ParseErrorLogger {
  const ParseErrorLogger();
  void logError(Object error, StackTrace stackTrace, dynamic options) {
    // You can implement logging here, or leave it empty for now
  }
}

@module
abstract class ElderApiModule {
  @LazySingleton()
  ElderApiService provideElderApiService(Dio dio) {
    final baseUrl = dotenv.env['BASE_URL'];
    return ElderApiService(dio, baseUrl: baseUrl);
  }
}

@RestApi()
abstract class ElderApiService {
  factory ElderApiService(Dio dio, {String? baseUrl}) = _ElderApiService;

  @POST('/api/Elder/CreateElder')
  Future<ElderResponse> createElder(@Body() ElderRequest request);

  @GET('/api/Elder/GetMyElders')
  Future<ElderListResponse> getMyElders();

  @PUT('/api/Elder/UpdateElderCategory')
  Future<void> updateElderCategory(
    @Query('elderId') String elderId,
    @Body() List<Map<String, String>> categories,
  );
}
