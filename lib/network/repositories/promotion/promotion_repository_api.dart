import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/models/base_response.dart';
import '../../../models/promotion_response.dart';
import '../../data/api_response_handler.dart';
import '../../data/promotion_api_service.dart';
import 'promotion_repository.dart';

@LazySingleton(as: PromotionRepository, env: [Environment.prod])
class PromotionRepositoryApi implements PromotionRepository {
  final PromotionApiService _apiService;

  PromotionRepositoryApi(this._apiService);

  @override
  Future<BaseResponse<PromotionResponse>> getAllPromotions() async {
    try {
      final response = await _apiService.getAllPromotions();
      return BaseResponse.success(data: response);
    } on DioException catch (e) {
      return ApiResponseHandler.handleError<PromotionResponse>(e);
    } catch (e) {
      return BaseResponse.error(message: e.toString());
    }
  }
}
