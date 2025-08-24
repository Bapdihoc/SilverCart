import 'package:injectable/injectable.dart';
import '../../core/models/base_response.dart';
import '../../models/promotion_response.dart';
import '../repositories/promotion/promotion_repository.dart';

@lazySingleton
class PromotionService {
  final PromotionRepository _repository;

  PromotionService(this._repository);

  Future<BaseResponse<PromotionResponse>> getAllPromotions() async {
    return await _repository.getAllPromotions();
  }

  // Helper method to get only valid and active promotions
  Future<List<PromotionData>> getValidPromotions() async {
    final result = await getAllPromotions();
    if (result.isSuccess && result.data != null) {
      return result.data!.data
          .where((promo) => promo.isValidAndActive)
          .toList();
    }
    return [];
  }
}
