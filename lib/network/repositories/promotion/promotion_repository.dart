import '../../../core/models/base_response.dart';
import '../../../models/promotion_response.dart';

abstract class PromotionRepository {
  Future<BaseResponse<PromotionResponse>> getAllPromotions();
}
