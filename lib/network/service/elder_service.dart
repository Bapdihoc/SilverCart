import 'package:injectable/injectable.dart';
import 'package:silvercart/core/models/base_response.dart';
import 'package:silvercart/models/elder_request.dart';
import 'package:silvercart/models/elder_list_response.dart';
import 'package:silvercart/network/repositories/elder/elder_repository.dart';

@LazySingleton()
class ElderService {
  final ElderRepository _repo;
  
  ElderService(this._repo);

  Future<BaseResponse> createElder(ElderRequest request) async {
    return await _repo.createElder(request);
  }

  Future<BaseResponse<ElderListResponse>> getMyElders() async {
    return await _repo.getMyElders();
  }
}
