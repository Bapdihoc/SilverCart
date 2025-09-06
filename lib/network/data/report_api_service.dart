import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/report_response.dart';

part 'report_api_service.g.dart';

@RestApi()
abstract class ReportApiService {
  factory ReportApiService(Dio dio, {String baseUrl}) = _ReportApiService;

  @GET('/api/Report/GetByUserId')
  Future<ReportResponse> getReportsByUserId(
    @Query('userId') String userId,
  );
}
