import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/category_list_response.dart';
import '../../models/root_category_response.dart';

part 'category_api_service.g.dart';

@RestApi()
abstract class CategoryApiService {
  factory CategoryApiService(Dio dio) = _CategoryApiService;

  @GET('/api/Category/GetListCategory')
  Future<CategoryListResponse> getListCategory();

  @GET('/api/Category/GetRootListValueCategory')
  Future<RootCategoryResponse> getRootListValueCategory();

  @GET('/api/Category/GetListValueCategoryById')
  Future<RootCategoryResponse> getListValueCategoryById(@Query('id') String id);
}

class ParseErrorLogger {
  void logError(dynamic error, StackTrace stackTrace, dynamic options) {
    print('🔥 CategoryApiService Parse Error: $error');
    print('🔥 StackTrace: $stackTrace');
  }
}
