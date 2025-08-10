import 'package:injectable/injectable.dart';
import '../../core/models/base_response.dart';
import '../../models/category_list_response.dart';
import '../../models/root_category_response.dart';
import '../repositories/category/category_repository.dart';

@LazySingleton()
class CategoryService {
  final CategoryRepository _repository;

  CategoryService(this._repository);

  Future<BaseResponse<CategoryListResponse>> getListCategory() async {
    return await _repository.getListCategory();
  }

  Future<BaseResponse<RootCategoryResponse>> getRootListValueCategory() async {
    return await _repository.getRootListValueCategory();
  }

  Future<BaseResponse<RootCategoryResponse>> getListValueCategoryById(String id) async {
    return await _repository.getListValueCategoryById(id);
  }
}
