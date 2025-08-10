import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/elder_request.dart';
import 'package:silvercart/models/elder_list_response.dart';
import 'package:silvercart/network/repositories/elder/elder_repository.dart';

@LazySingleton(as: ElderRepository, env: [Environment.dev])
class ElderRepositoryMock implements ElderRepository {
  @override
  Future<BaseResponse> createElder(ElderRequest request) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock successful response
    return BaseResponse.success(
      data: {
        'message': 'Tạo người thân thành công',
        'elderId': 'mock-elder-id-123',
      },
    );
  }

  @override
  Future<BaseResponse<ElderListResponse>> getMyElders() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful response
    return BaseResponse.success(
      data: ElderListResponse(
        message: 'Get elder successfully.',
        data: [
          ElderData(
            id: '1e5e183e-5922-464a-a8df-9258fc98740c',
            fullName: 'Nguyen Van CX',
            userName: 'Nguyen Van CX',
            description: 'benh de',
            birthDate: DateTime(1950, 1, 1),
            spendLimit: 12000000,
            emergencyPhoneNumber: '0909898900',
            relationShip: 'Ông',
            isDelete: false,
            avatar: null,
            gender: 0,
            addresses: [
              ElderAddressData(
                id: '811695df-770e-4b39-f871-08ddd5d8ec40',
                streetAddress: '9426c',
                wardCode: '510802',
                wardName: 'Xã Bình Chánh',
                districtID: 1758,
                districtName: 'Huyện Châu Phú',
                provinceID: 217,
                provinceName: 'An Giang',
                phoneNumber: '0787878909',
              ),
            ],
            categories: ['1e5e183e-5922-464a-a8df-9258fc98720d'],
          ),
        ],
      ),
    );
  }
}
