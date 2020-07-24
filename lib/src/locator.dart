import 'package:get_it/get_it.dart';
import 'package:eszaworker/src/services/background_fetch_service.dart';
import 'package:eszaworker/src/services/location_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => LocationService());
  locator.registerLazySingleton(() => BackgroundFetchService());
}