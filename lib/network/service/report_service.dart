import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/report_response.dart';
import 'package:silvercart/network/repositories/report/report_repository.dart';

@LazySingleton()
class ReportService {
  final ReportRepository _repo;
  
  ReportService(this._repo);

  Future<BaseResponse<ReportResponse>> getReportsByUserId(String userId) async {
    return await _repo.getReportsByUserId(userId);
  }
}
