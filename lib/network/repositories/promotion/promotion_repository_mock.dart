import 'package:injectable/injectable.dart';
import '../../../core/models/base_response.dart';
import '../../../models/promotion_response.dart';
import 'promotion_repository.dart';

@LazySingleton(as: PromotionRepository, env: [Environment.dev])
class PromotionRepositoryMock implements PromotionRepository {
  @override
  Future<BaseResponse<PromotionResponse>> getAllPromotions() async {
    await Future.delayed(const Duration(seconds: 1));

    final mockData = [
      PromotionData(
        id: '33291f23-4ec3-49a7-c166-08dddb3a8074',
        title: 'Giảm giá 20%',
        description: 'Giảm giá 20% cho đơn hàng từ 500.000đ',
        discountPercent: 20,
        requiredPoints: 0,
        startAt: '2024-01-01T00:00:00+00:00',
        endAt: '2024-12-31T23:59:59+00:00',
        isActive: true,
        creationDate: '2024-01-01T00:00:00+00:00',
      ),
      PromotionData(
        id: 'promo-2',
        title: 'Miễn phí vận chuyển',
        description: 'Miễn phí vận chuyển cho đơn hàng trên 300.000đ',
        discountPercent: 0,
        requiredPoints: 100,
        startAt: '2024-01-01T00:00:00+00:00',
        endAt: '2024-12-31T23:59:59+00:00',
        isActive: true,
        creationDate: '2024-01-01T00:00:00+00:00',
      ),
      PromotionData(
        id: 'promo-3',
        title: 'Giảm 15% cho thành viên VIP',
        description: 'Dành riêng cho khách hàng thân thiết',
        discountPercent: 15,
        requiredPoints: 500,
        startAt: '2024-01-01T00:00:00+00:00',
        endAt: '2024-12-31T23:59:59+00:00',
        isActive: true,
        creationDate: '2024-01-01T00:00:00+00:00',
      ),
    ];

    final response = PromotionResponse(
      message: 'Promotion getlist successfully',
      data: mockData,
    );

    return BaseResponse.success(data: response);
  }
}
