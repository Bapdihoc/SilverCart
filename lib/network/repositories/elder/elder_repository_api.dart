import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/elder_request.dart';
import 'package:silvercart/models/update_elder_request.dart';
import 'package:silvercart/models/update_elder_address_request.dart';
import 'package:silvercart/models/elder_list_response.dart';
import 'package:silvercart/network/data/elder_api_service.dart';
import 'package:silvercart/network/data/api_response_handler.dart';
import 'package:silvercart/network/repositories/elder/elder_repository.dart';

@LazySingleton(as: ElderRepository, env: [Environment.prod])
class ElderRepositoryApi implements ElderRepository {
  final ElderApiService _api;
  
  ElderRepositoryApi(this._api);

  @override
  Future<BaseResponse> createElder(ElderRequest request) async {
    try {
      final response = await _api.createElder(request);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse> updateElder(UpdateElderRequest request) async {
    try {
      final response = await _api.updateElder(request);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse> updateElderAddress(String elderId, List<UpdateElderAddressRequest> addresses) async {
    try {
      final response = await _api.updateElderAddress(elderId, addresses);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<ElderListResponse>> getMyElders() async {
    try {
      final response = await _api.getMyElders();
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<ElderListResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<void>> updateElderCategory(String elderId, List<Map<String, String>> categories) async {
    try {
      // Pass the categories array directly as the body
      await _api.updateElderCategory(elderId, categories);
      return BaseResponse.success(data: null);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<void>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }
}
