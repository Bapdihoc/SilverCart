import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/report_response.dart';
import 'package:silvercart/network/data/api_response_handler.dart';
import 'package:silvercart/network/data/report_api_service.dart';
import 'package:silvercart/network/repositories/report/report_repository.dart';
import 'package:dio/dio.dart';

@LazySingleton(as: ReportRepository, env: ['prod'])
class ReportRepositoryApi implements ReportRepository {
  final ReportApiService _api;

  ReportRepositoryApi(this._api);

  @override
  Future<BaseResponse<ReportResponse>> getReportsByUserId(String userId) async {
    try {
      final response = await _api.getReportsByUserId(userId);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<ReportResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }
}
