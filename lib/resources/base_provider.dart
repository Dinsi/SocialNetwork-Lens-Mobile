import 'package:aperture/locator.dart';
import 'package:aperture/resources/AppInfo.dart';

abstract class BaseProvider {
  final String baseUrl = 'https://lens.technic.pt/api/v1/';
  final AppInfo appInfo = locator<AppInfo>();
}
