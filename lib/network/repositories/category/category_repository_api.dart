import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/models/base_response.dart';
import '../../../models/category_list_response.dart';
import '../../../models/root_category_response.dart';
import '../../data/category_api_service.dart';
import '../../data/api_response_handler.dart';
import 'category_repository.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryApi implements CategoryRepository {
  final CategoryApiService _api;

  CategoryRepositoryApi(this._api);

  @override
  Future<BaseResponse<CategoryListResponse>> getListCategory() async {
    try {
      final response = await _api.getListCategory();
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<CategoryListResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<RootCategoryResponse>> getRootListValueCategory() async {
    try {
      final response = await _api.getRootListValueCategory();
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<RootCategoryResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }

  @override
  Future<BaseResponse<RootCategoryResponse>> getListValueCategoryById(String id) async {
    try {
      final response = await _api.getListValueCategoryById(id);
      return BaseResponse.success(data: response);
    } catch (e) {
      if (e is DioException) {
        return ApiResponseHandler.handleError<RootCategoryResponse>(e);
      }
      return BaseResponse.error(message: e.toString());
    }
  }
}
