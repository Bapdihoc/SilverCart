import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart'; // file này được generate
import 'network/service/speech_service.dart';
import 'network/service/agora_service.dart';

final GetIt getIt = GetIt.instance;

@injectableInit
Future<void> configureDependencies(String environment) async {
  await getIt.init(environment: environment);
}