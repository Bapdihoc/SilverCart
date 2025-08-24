import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/promotion_response.dart';

part 'promotion_api_service.g.dart';

@RestApi()
abstract class PromotionApiService {
  factory PromotionApiService(Dio dio, {String baseUrl}) = _PromotionApiService;

  @GET('/api/Promotion/GetAll')
  Future<PromotionResponse> getAllPromotions();
}
