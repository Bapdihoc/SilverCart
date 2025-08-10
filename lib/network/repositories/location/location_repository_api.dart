import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/province_model.dart';
import 'package:silvercart/models/district_model.dart';
import 'package:silvercart/models/ward_model.dart';
import 'package:silvercart/network/data/location_api_service.dart';
import 'package:silvercart/network/data/api_response_handler.dart';
import 'package:silvercart/network/repositories/location/location_repository.dart';

@LazySingleton(as: LocationRepository, env: [Environment.prod])
class LocationRepositoryApi implements LocationRepository {
  final LocationApiService _api;
  
  LocationRepositoryApi(this._api);

  @override
  Future<BaseResponse<ProvinceResponse>> getProvinces() async {
    try {
      final response = await _api.getProvinces();
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<ProvinceResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<DistrictResponse>> getDistricts(int provinceId) async {
    try {
      final response = await _api.getDistricts(provinceId);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<DistrictResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<WardResponse>> getWards(int districtId) async {
    try {
      final response = await _api.getWards(districtId);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<WardResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }
}
