import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/report_response.dart';
import 'package:silvercart/network/repositories/report/report_repository.dart';

@LazySingleton(as: ReportRepository, env: ['dev'])
class ReportRepositoryMock implements ReportRepository {
  @override
  Future<BaseResponse<ReportResponse>> getReportsByUserId(String userId) async {
    // Mock data for testing
    await Future.delayed(const Duration(seconds: 1));
    
    final mockData = ReportResponse(
      message: "Get report by userId successfully",
      data: [
        ReportData(
          id: "39c39d05-62c8-41d0-0c8c-08ddebd1b37f",
          title: "Ensure Gold 237ml",
          description: "<p>Tư vấn về sữa Ensure Gold 237ml cho cụ để dễ dàng lựa chọn sản phẩm</p>\n<p><a href=\"https://silvercart.netlify.app/products/A9416F72-91DD-46CA-2588-08DDE726BC1F\">https://silvercart.netlify.app/products/A9416F72-91DD-46CA-2588-08DDE726BC1F</a><br><br><br></p>",
          userId: userId,
          consultantId: "cef01568-2ad0-4a16-1fde-08dde727e2b1",
        ),
        ReportData(
          id: "39c39d05-62c8-41d0-0c8c-08ddebd1b37g",
          title: "Sữa Ensure Plus",
          description: "<p>Tư vấn về sữa Ensure Plus cho người cao tuổi</p>",
          userId: userId,
          consultantId: "cef01568-2ad0-4a16-1fde-08dde727e2b1",
        ),
      ],
    );
    
    return BaseResponse.success(data: mockData);
  }
}
