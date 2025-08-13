import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/elder_request.dart';
import 'package:silvercart/models/elder_list_response.dart';

abstract class ElderRepository {
  Future<BaseResponse> createElder(ElderRequest request);
  Future<BaseResponse<ElderListResponse>> getMyElders();
  Future<BaseResponse<void>> updateElderCategory(String elderId, List<Map<String, String>> categories);
}
