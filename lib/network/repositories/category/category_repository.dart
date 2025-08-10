import '../../../core/models/base_response.dart';
import '../../../models/category_list_response.dart';
import '../../../models/root_category_response.dart';

abstract class CategoryRepository {
  Future<BaseResponse<CategoryListResponse>> getListCategory();
  Future<BaseResponse<RootCategoryResponse>> getRootListValueCategory();
  Future<BaseResponse<RootCategoryResponse>> getListValueCategoryById(String id);
}
