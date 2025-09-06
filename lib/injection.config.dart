// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:silvercart/network/data/auth_api_service.dart' as _i440;
import 'package:silvercart/network/data/cart_api_service.dart' as _i66;
import 'package:silvercart/network/data/category_api_service.dart' as _i109;
import 'package:silvercart/network/data/dio_module.dart' as _i548;
import 'package:silvercart/network/data/elder_api_service.dart' as _i269;
import 'package:silvercart/network/data/location_api_service.dart' as _i662;
import 'package:silvercart/network/data/order_api_service.dart' as _i244;
import 'package:silvercart/network/data/payment_history_api_service.dart'
    as _i612;
import 'package:silvercart/network/data/product_api_service.dart' as _i795;
import 'package:silvercart/network/data/promotion_api_service.dart' as _i664;
import 'package:silvercart/network/data/report_api_service.dart' as _i1017;
import 'package:silvercart/network/data/shipping_api_service.dart' as _i794;
import 'package:silvercart/network/data/wallet_api_service.dart' as _i489;
import 'package:silvercart/network/repositories/auth/auth_repository.dart'
    as _i69;
import 'package:silvercart/network/repositories/auth/auth_repository_api.dart'
    as _i749;
import 'package:silvercart/network/repositories/auth/auth_repository_mock.dart'
    as _i516;
import 'package:silvercart/network/repositories/cart/cart_repository.dart'
    as _i776;
import 'package:silvercart/network/repositories/category/category_repository.dart'
    as _i805;
import 'package:silvercart/network/repositories/category/category_repository_api.dart'
    as _i229;
import 'package:silvercart/network/repositories/elder/elder_repository.dart'
    as _i40;
import 'package:silvercart/network/repositories/elder/elder_repository_api.dart'
    as _i437;
import 'package:silvercart/network/repositories/elder/elder_repository_mock.dart'
    as _i486;
import 'package:silvercart/network/repositories/location/location_repository.dart'
    as _i136;
import 'package:silvercart/network/repositories/location/location_repository_api.dart'
    as _i871;
import 'package:silvercart/network/repositories/location/location_repository_mock.dart'
    as _i985;
import 'package:silvercart/network/repositories/order/order_respository.dart'
    as _i213;
import 'package:silvercart/network/repositories/order/order_respository_api.dart'
    as _i654;
import 'package:silvercart/network/repositories/order/order_respository_mock.dart'
    as _i61;
import 'package:silvercart/network/repositories/payment_history/payment_history_repository.dart'
    as _i339;
import 'package:silvercart/network/repositories/payment_history/payment_history_repository_api.dart'
    as _i400;
import 'package:silvercart/network/repositories/payment_history/payment_history_repository_mock.dart'
    as _i28;
import 'package:silvercart/network/repositories/product/product_repository.dart'
    as _i249;
import 'package:silvercart/network/repositories/product/product_repository_api.dart'
    as _i975;
import 'package:silvercart/network/repositories/product/product_repository_mock.dart'
    as _i853;
import 'package:silvercart/network/repositories/promotion/promotion_repository.dart'
    as _i258;
import 'package:silvercart/network/repositories/promotion/promotion_repository_api.dart'
    as _i95;
import 'package:silvercart/network/repositories/promotion/promotion_repository_mock.dart'
    as _i1010;
import 'package:silvercart/network/repositories/report/report_repository.dart'
    as _i688;
import 'package:silvercart/network/repositories/report/report_repository_api.dart'
    as _i634;
import 'package:silvercart/network/repositories/report/report_repository_mock.dart'
    as _i1035;
import 'package:silvercart/network/repositories/shipping/shipping_repository.dart'
    as _i745;
import 'package:silvercart/network/repositories/shipping/shipping_repository_api.dart'
    as _i935;
import 'package:silvercart/network/repositories/shipping/shipping_repository_mock.dart'
    as _i38;
import 'package:silvercart/network/repositories/wallet/wallet_repository.dart'
    as _i485;
import 'package:silvercart/network/repositories/wallet/wallet_repository_api.dart'
    as _i361;
import 'package:silvercart/network/repositories/wallet/wallet_repository_mock.dart'
    as _i1062;
import 'package:silvercart/network/service/agora_service.dart' as _i50;
import 'package:silvercart/network/service/auth_service.dart' as _i567;
import 'package:silvercart/network/service/cart_service.dart' as _i971;
import 'package:silvercart/network/service/cart_service_module.dart' as _i758;
import 'package:silvercart/network/service/category_service.dart' as _i144;
import 'package:silvercart/network/service/elder_service.dart' as _i1046;
import 'package:silvercart/network/service/location_service.dart' as _i484;
import 'package:silvercart/network/service/order_service.dart' as _i212;
import 'package:silvercart/network/service/payment_history_service.dart'
    as _i124;
import 'package:silvercart/network/service/product_service.dart' as _i24;
import 'package:silvercart/network/service/promotion_service.dart' as _i231;
import 'package:silvercart/network/service/report_service.dart' as _i939;
import 'package:silvercart/network/service/shipping_service.dart' as _i274;
import 'package:silvercart/network/service/speech_service.dart' as _i773;
import 'package:silvercart/network/service/user_session_service.dart' as _i385;
import 'package:silvercart/network/service/wallet_service.dart' as _i800;

const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    final cartApiModule = _$CartApiModule();
    final elderApiModule = _$ElderApiModule();
    final productApiModule = _$ProductApiModule();
    final orderApiModule = _$OrderApiModule();
    final walletApiModule = _$WalletApiModule();
    final authApiModule = _$AuthApiModule();
    final shippingApiModule = _$ShippingApiModule();
    final locationApiModule = _$LocationApiModule();
    final cartServiceModule = _$CartServiceModule();
    gh.singleton<_i50.AgoraService>(() => _i50.AgoraService());
    gh.singleton<_i773.SpeechService>(() => _i773.SpeechService());
    gh.lazySingleton<_i385.UserSessionService>(
      () => _i385.UserSessionService(),
    );
    gh.lazySingleton<_i361.Dio>(() => dioModule.provideDio());
    gh.lazySingleton<_i213.OrderRespository>(
      () => _i61.OrderRespositoryMock(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i40.ElderRepository>(
      () => _i486.ElderRepositoryMock(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i745.ShippingRepository>(
      () => _i38.ShippingRepositoryMock(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i258.PromotionRepository>(
      () => _i1010.PromotionRepositoryMock(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i69.AuthRepository>(
      () => _i516.AuthRepositoryMock(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i249.ProductRepository>(
      () => _i853.ProductRepositoryMock(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i1046.ElderService>(
      () => _i1046.ElderService(gh<_i40.ElderRepository>()),
    );
    gh.lazySingleton<_i136.LocationRepository>(
      () => _i985.LocationRepositoryMock(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i109.CategoryApiService>(
      () => dioModule.provideCategoryApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i664.PromotionApiService>(
      () => dioModule.providePromotionApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i612.PaymentHistoryApiService>(
      () => dioModule.providePaymentHistoryApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1017.ReportApiService>(
      () => dioModule.provideReportApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i66.CartApiService>(
      () => cartApiModule.provideCartApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i269.ElderApiService>(
      () => elderApiModule.provideElderApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i795.ProductApiService>(
      () => productApiModule.provideProductApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i244.OrderApiService>(
      () => orderApiModule.provideOrderApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i489.WalletApiService>(
      () => walletApiModule.provideWalletApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i440.AuthApiService>(
      () => authApiModule.provideAuthApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i794.ShippingApiService>(
      () => shippingApiModule.provideShippingApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i662.LocationApiService>(
      () => locationApiModule.provideLocationApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i231.PromotionService>(
      () => _i231.PromotionService(gh<_i258.PromotionRepository>()),
    );
    gh.lazySingleton<_i69.AuthRepository>(
      () => _i749.AuthRepositoryApi(gh<_i440.AuthApiService>()),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i688.ReportRepository>(
      () => _i1035.ReportRepositoryMock(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i339.PaymentHistoryRepository>(
      () => _i28.PaymentHistoryRepositoryMock(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i485.WalletRepository>(
      () => _i1062.WalletRepositoryMock(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i136.LocationRepository>(
      () => _i871.LocationRepositoryApi(gh<_i662.LocationApiService>()),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i484.LocationService>(
      () => _i484.LocationService(gh<_i136.LocationRepository>()),
    );
    gh.lazySingleton<_i212.OrderService>(
      () => _i212.OrderService(gh<_i213.OrderRespository>()),
    );
    gh.lazySingleton<_i258.PromotionRepository>(
      () => _i95.PromotionRepositoryApi(gh<_i664.PromotionApiService>()),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i805.CategoryRepository>(
      () => _i229.CategoryRepositoryApi(gh<_i109.CategoryApiService>()),
    );
    gh.lazySingleton<_i339.PaymentHistoryRepository>(
      () => _i400.PaymentHistoryRepositoryApi(
        gh<_i612.PaymentHistoryApiService>(),
      ),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i274.ShippingService>(
      () => _i274.ShippingService(gh<_i745.ShippingRepository>()),
    );
    gh.lazySingleton<_i24.ProductService>(
      () => _i24.ProductService(gh<_i249.ProductRepository>()),
    );
    gh.lazySingleton<_i688.ReportRepository>(
      () => _i634.ReportRepositoryApi(gh<_i1017.ReportApiService>()),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i800.WalletService>(
      () => _i800.WalletService(gh<_i485.WalletRepository>()),
    );
    gh.lazySingleton<_i939.ReportService>(
      () => _i939.ReportService(gh<_i688.ReportRepository>()),
    );
    gh.lazySingleton<_i40.ElderRepository>(
      () => _i437.ElderRepositoryApi(gh<_i269.ElderApiService>()),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i485.WalletRepository>(
      () => _i361.WalletRepositoryApi(gh<_i489.WalletApiService>()),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i776.CartRepository>(
      () => cartServiceModule.provideCartRepository(gh<_i66.CartApiService>()),
    );
    gh.lazySingleton<_i124.PaymentHistoryService>(
      () => _i124.PaymentHistoryService(gh<_i339.PaymentHistoryRepository>()),
    );
    gh.lazySingleton<_i567.AuthService>(
      () => _i567.AuthService(gh<_i69.AuthRepository>()),
    );
    gh.lazySingleton<_i249.ProductRepository>(
      () => _i975.ProductRepositoryApi(gh<_i795.ProductApiService>()),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i971.CartService>(
      () => cartServiceModule.provideCartService(gh<_i776.CartRepository>()),
    );
    gh.lazySingleton<_i144.CategoryService>(
      () => _i144.CategoryService(gh<_i805.CategoryRepository>()),
    );
    gh.lazySingleton<_i213.OrderRespository>(
      () => _i654.OrderRespositoryApi(gh<_i244.OrderApiService>()),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i745.ShippingRepository>(
      () => _i935.ShippingRepositoryApi(gh<_i794.ShippingApiService>()),
      registerFor: {_prod},
    );
    return this;
  }
}

class _$DioModule extends _i548.DioModule {}

class _$CartApiModule extends _i66.CartApiModule {}

class _$ElderApiModule extends _i269.ElderApiModule {}

class _$ProductApiModule extends _i795.ProductApiModule {}

class _$OrderApiModule extends _i244.OrderApiModule {}

class _$WalletApiModule extends _i489.WalletApiModule {}

class _$AuthApiModule extends _i440.AuthApiModule {}

class _$ShippingApiModule extends _i794.ShippingApiModule {}

class _$LocationApiModule extends _i662.LocationApiModule {}

class _$CartServiceModule extends _i758.CartServiceModule {}
