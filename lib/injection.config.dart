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
import 'package:silvercart/network/data/dio_module.dart' as _i548;
import 'package:silvercart/network/data/order_api_service.dart' as _i244;
import 'package:silvercart/network/data/product_api_service.dart' as _i795;
import 'package:silvercart/network/repositories/auth/auth_repository.dart'
    as _i69;
import 'package:silvercart/network/repositories/auth/auth_repository_api.dart'
    as _i749;
import 'package:silvercart/network/repositories/auth/auth_repository_mock.dart'
    as _i516;
import 'package:silvercart/network/repositories/order/order_respository.dart'
    as _i213;
import 'package:silvercart/network/repositories/order/order_respository_api.dart'
    as _i654;
import 'package:silvercart/network/repositories/order/order_respository_mock.dart'
    as _i61;
import 'package:silvercart/network/repositories/product/product_repository.dart'
    as _i249;
import 'package:silvercart/network/repositories/product/product_repository_api.dart'
    as _i975;
import 'package:silvercart/network/repositories/product/product_repository_mock.dart'
    as _i853;
import 'package:silvercart/network/service/auth_service.dart' as _i567;
import 'package:silvercart/network/service/product_service.dart' as _i24;
import 'package:silvercart/network/service/user_session_service.dart' as _i385;

const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final dioModule = _$DioModule();
    final authApiModule = _$AuthApiModule();
    final productApiModule = _$ProductApiModule();
    final orderApiModule = _$OrderApiModule();
    gh.lazySingleton<_i385.UserSessionService>(
        () => _i385.UserSessionService());
    gh.lazySingleton<_i361.Dio>(() => dioModule.provideDio());
    gh.lazySingleton<_i213.OrderRespository>(
      () => _i61.OrderRespositoryMock(),
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
    gh.lazySingleton<_i440.AuthApiService>(
        () => authApiModule.provideAuthApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i795.ProductApiService>(
        () => productApiModule.provideProductApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i244.OrderApiService>(
        () => orderApiModule.provideOrderApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i69.AuthRepository>(
      () => _i749.AuthRepositoryApi(gh<_i440.AuthApiService>()),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i24.ProductService>(
        () => _i24.ProductService(gh<_i249.ProductRepository>()));
    gh.lazySingleton<_i567.AuthService>(
        () => _i567.AuthService(gh<_i69.AuthRepository>()));
    gh.lazySingleton<_i249.ProductRepository>(
      () => _i975.ProductRepositoryApi(gh<_i795.ProductApiService>()),
      registerFor: {_prod},
    );
    gh.lazySingleton<_i213.OrderRespository>(
      () => _i654.OrderRespositoryApi(gh<_i244.OrderApiService>()),
      registerFor: {_prod},
    );
    return this;
  }
}

class _$DioModule extends _i548.DioModule {}

class _$AuthApiModule extends _i440.AuthApiModule {}

class _$ProductApiModule extends _i795.ProductApiModule {}

class _$OrderApiModule extends _i244.OrderApiModule {}
