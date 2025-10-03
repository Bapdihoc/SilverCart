import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/report_response.dart';

abstract class ReportRepository {
  Future<BaseResponse<ReportResponse>> getReportsByUserId(String userId);
}
