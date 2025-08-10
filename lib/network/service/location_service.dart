import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/province_model.dart';
import 'package:silvercart/models/district_model.dart';
import 'package:silvercart/models/ward_model.dart';
import 'package:silvercart/network/repositories/location/location_repository.dart';

@LazySingleton()
class LocationService {
  final LocationRepository _repo;
  
  LocationService(this._repo);

  Future<BaseResponse<ProvinceResponse>> getProvinces() async {
    return await _repo.getProvinces();
  }

  Future<BaseResponse<DistrictResponse>> getDistricts(int provinceId) async {
    return await _repo.getDistricts(provinceId);
  }

  Future<BaseResponse<WardResponse>> getWards(int districtId) async {
    return await _repo.getWards(districtId);
  }
}
