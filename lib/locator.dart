import 'package:aperture/resources/app_info.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt();

void setupLocator() {
  locator.registerLazySingleton(() => AppInfo());
}
