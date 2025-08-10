import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/province_model.dart';
import 'package:silvercart/models/district_model.dart';
import 'package:silvercart/models/ward_model.dart';

abstract class LocationRepository {
  Future<BaseResponse<ProvinceResponse>> getProvinces();
  Future<BaseResponse<DistrictResponse>> getDistricts(int provinceId);
  Future<BaseResponse<WardResponse>> getWards(int districtId);
}
