import 'package:injectable/injectable.dart';
import '../../../core/models/base_response.dart';
import '../../../models/payment_history_response.dart';
import 'payment_history_repository.dart';

@LazySingleton(as: PaymentHistoryRepository, env: [Environment.dev])
class PaymentHistoryRepositoryMock implements PaymentHistoryRepository {
  @override
  Future<BaseResponse<PaymentHistoryResponse>> searchPaymentHistory(
      PaymentHistorySearchRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final mockItems = [
      PaymentHistoryItem(
        id: "287B3933-E366-483E-1653-08DDDB68B746",
        amount: 41000,
        userId: "6F8EE4E3-B00A-47F7-B06A-278AAA5AF967",
        userName: "NGUYEN VAN C",
        avatar: null,
        paymentMenthod: "VNPay",
        paymentStatus: 1,
        creationDate: DateTime.now().subtract(const Duration(hours: 5)),
        orderId: "EC7BC731-FC0D-47BB-C65E-08DDDB68B743",
      ),
      PaymentHistoryItem(
        id: "5E8EB699-83C0-477F-54E6-08DDDA9E32F7",
        amount: 2184600,
        userId: "6F8EE4E3-B00A-47F7-B06A-278AAA5AF967",
        userName: "NGUYEN VAN C",
        avatar: 'https://example.com/avatar.jpg',
        paymentMenthod: "VNPay",
        paymentStatus: 1,
        creationDate: DateTime.now().subtract(const Duration(days: 1)),
        orderId: "0AB0280B-EA09-4FF4-16CA-08DDDA9E32F5",
      ),
      PaymentHistoryItem(
        id: "ABC123-DEF456-GHI789",
        amount: 150000,
        userId: "6F8EE4E3-B00A-47F7-B06A-278AAA5AF967",
        userName: "NGUYEN VAN C",
        avatar: null,
        paymentMenthod: "PayOS",
        paymentStatus: 2,
        creationDate: DateTime.now().subtract(const Duration(days: 3)),
        orderId: "ORDER123-456",
      ),
      PaymentHistoryItem(
        id: "XYZ789-ABC123-DEF456",
        amount: 75000,
        userId: "6F8EE4E3-B00A-47F7-B06A-278AAA5AF967",
        userName: "NGUYEN VAN C",
        avatar: null,
        paymentMenthod: "Wallet",
        paymentStatus: 0,
        creationDate: DateTime.now().subtract(const Duration(days: 7)),
        orderId: "ORDER789-123",
      ),
    ];

    final response = PaymentHistoryResponse(
      message: "Search payment history successfully",
      data: PaymentHistoryData(
        totalItems: mockItems.length,
        items: mockItems,
      ),
    );

    return BaseResponse.success(data: response);
  }
}
