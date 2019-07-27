import 'package:aperture/locator.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:flutter/foundation.dart';

abstract class BaseApiProvider {
  @protected
  final String baseUrl = 'https://lens.technic.pt/api/v1/';

  @protected
  final AppInfo appInfo = locator<AppInfo>();
}
