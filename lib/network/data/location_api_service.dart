import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:silvercart/models/province_model.dart';
import 'package:silvercart/models/district_model.dart';
import 'package:silvercart/models/ward_model.dart';
part 'location_api_service.g.dart';

class ParseErrorLogger {
  const ParseErrorLogger();
  void logError(Object error, StackTrace stackTrace, dynamic options) {
    // You can implement logging here, or leave it empty for now
  }
}

@module
abstract class LocationApiModule {
  @LazySingleton()
  LocationApiService provideLocationApiService(Dio dio) {
    final baseUrl = dotenv.env['BASE_URL'];
    return LocationApiService(dio, baseUrl: baseUrl);
  }
}

@RestApi()
abstract class LocationApiService {
  factory LocationApiService(Dio dio, {String? baseUrl}) = _LocationApiService;

  @GET('/api/Location/GetProvinces')
  Future<ProvinceResponse> getProvinces();

  @GET('/api/Location/GetDistricts/{provinceId}')
  Future<DistrictResponse> getDistricts(@Path('provinceId') int provinceId);
  
  @GET('/api/Location/GetWards/{districtId}')
  Future<WardResponse> getWards(@Path('districtId') int districtId);
}
