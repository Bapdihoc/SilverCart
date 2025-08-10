import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/province_model.dart';
import 'package:silvercart/models/district_model.dart';
import 'package:silvercart/models/ward_model.dart';
import 'package:silvercart/network/repositories/location/location_repository.dart';

@LazySingleton(as: LocationRepository, env: [Environment.dev])
class LocationRepositoryMock implements LocationRepository {
  @override
  Future<BaseResponse<ProvinceResponse>> getProvinces() async {
    // Mock data
    final mockProvinces = [
      Province(
        provinceID: 217,
        provinceName: "An Giang",
        code: "76",
        id: "5e203ece-2132-454a-1632-08ddd5cb779e",
        isDeleted: false,
        rowVersion: "AAAAAAAACG8=",
      ),
      Province(
        provinceID: 218,
        provinceName: "Hà Nội",
        code: "01",
        id: "5e203ece-2132-454a-1632-08ddd5cb779f",
        isDeleted: false,
        rowVersion: "AAAAAAAACG9=",
      ),
      Province(
        provinceID: 219,
        provinceName: "TP. Hồ Chí Minh",
        code: "79",
        id: "5e203ece-2132-454a-1632-08ddd5cb77a0",
        isDeleted: false,
        rowVersion: "AAAAAAAACGA=",
      ),
    ];

    final mockResponse = ProvinceResponse(
      message: "Get provinces successfully",
      data: mockProvinces,
    );

    return BaseResponse.success(data: mockResponse);
  }

  @override
  Future<BaseResponse<DistrictResponse>> getDistricts(int provinceId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data based on provinceId
    List<District> mockDistricts = [];
    
    if (provinceId == 217) { // An Giang
      mockDistricts = [
        District(
          districtID: 1754,
          provinceID: 217,
          districtName: "Huyện An Phú",
          code: "5103",
          type: 3,
          supportType: 3,
          id: "acfb2c49-7a96-4620-23c2-08ddd5cb7825",
          isDeleted: false,
          rowVersion: "AAAAAAAACnc=",
        ),
        District(
          districtID: 1755,
          provinceID: 217,
          districtName: "Huyện Châu Phú",
          code: "5104",
          type: 3,
          supportType: 3,
          id: "acfb2c49-7a96-4620-23c2-08ddd5cb7826",
          isDeleted: false,
          rowVersion: "AAAAAAAACng=",
        ),
      ];
    } else if (provinceId == 218) { // Hà Nội
      mockDistricts = [
        District(
          districtID: 1756,
          provinceID: 218,
          districtName: "Quận Ba Đình",
          code: "0101",
          type: 2,
          supportType: 2,
          id: "acfb2c49-7a96-4620-23c2-08ddd5cb7827",
          isDeleted: false,
          rowVersion: "AAAAAAAACnk=",
        ),
        District(
          districtID: 1757,
          provinceID: 218,
          districtName: "Quận Hoàn Kiếm",
          code: "0102",
          type: 2,
          supportType: 2,
          id: "acfb2c49-7a96-4620-23c2-08ddd5cb7828",
          isDeleted: false,
          rowVersion: "AAAAAAAACno=",
        ),
      ];
    }

    return BaseResponse.success(
      data: DistrictResponse(
        message: "Get districts successfully",
        data: mockDistricts,
      ),
    );
  }

  @override
  Future<BaseResponse<WardResponse>> getWards(int districtId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data based on districtId
    List<Ward> mockWards = [];
    
    if (districtId == 1754) { // Huyện An Phú
      mockWards = [
        Ward(
          wardCode: "510301",
          districtID: 1754,
          wardName: "Thị trấn An Phú",
          id: "c30285b1-7307-4d1a-82d8-08ddd5cb7867",
          isDeleted: false,
          rowVersion: "AAAAAAAAL0I=",
        ),
        Ward(
          wardCode: "510302",
          districtID: 1754,
          wardName: "Xã Khánh An",
          id: "c30285b1-7307-4d1a-82d8-08ddd5cb7868",
          isDeleted: false,
          rowVersion: "AAAAAAAAL0M=",
        ),
      ];
    } else if (districtId == 1756) { // Quận Ba Đình
      mockWards = [
        Ward(
          wardCode: "010101",
          districtID: 1756,
          wardName: "Phường Phúc Xá",
          id: "c30285b1-7307-4d1a-82d8-08ddd5cb7869",
          isDeleted: false,
          rowVersion: "AAAAAAAAL0Q=",
        ),
        Ward(
          wardCode: "010102",
          districtID: 1756,
          wardName: "Phường Trúc Bạch",
          id: "c30285b1-7307-4d1a-82d8-08ddd5cb7870",
          isDeleted: false,
          rowVersion: "AAAAAAAAL0U=",
        ),
      ];
    }

    return BaseResponse.success(
      data: WardResponse(
        message: "Get wards successfully",
        data: mockWards,
      ),
    );
  }
}
