import 'package:webview_flutter/webview_flutter.dart';

abstract class RouterStrategy {
  Future<void> login(WebViewController controller );

  Future<void> changeWifiSettings(WebViewController controller ,String wlSsid ,String wlWpaPsk , context);

  Future<void> reboot(WebViewController controller, context);

  Future<void> wan(WebViewController controller, String selectedHuaweiOption  , String username , String password);

  Future<void> lan(WebViewController controller);

  String get loginUrl;
}