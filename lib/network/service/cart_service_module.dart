import 'package:injectable/injectable.dart';
import 'package:silvercart/network/data/cart_api_service.dart';
import 'package:silvercart/network/repositories/cart/cart_repository.dart';
import 'package:silvercart/network/repositories/cart/cart_repository_api.dart';
import 'package:silvercart/network/repositories/cart/cart_repository_mock.dart';
import 'package:silvercart/network/service/cart_service.dart';

@module
abstract class CartServiceModule {
  @LazySingleton()
  CartRepository provideCartRepository(CartApiService apiService) {
    // Use API for production
    return CartRepositoryApi(apiService);
  }

  @LazySingleton()
  CartService provideCartService(CartRepository repository) {
    return CartService(repository);
  }
}
