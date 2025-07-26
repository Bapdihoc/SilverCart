import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart'; // file này được generate

final GetIt getIt = GetIt.instance;

@injectableInit
Future<void> configureDependencies(String environment) async {
  await getIt.init(environment: environment);
}