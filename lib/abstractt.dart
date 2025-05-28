import 'package:webview_flutter/webview_flutter.dart';

abstract class RouterStrategy {
  Future<void> login(WebViewController controller );

  Future<void> startCenter(WebViewController controller );
  Future<void> lan(WebViewController controller);
  Future<void> wan(WebViewController controller, String selectedHuaweiOption  , String username , String password);
  Future<void> changeWifiSettings(WebViewController controller ,String wlSsid ,String wlWpaPsk );
  Future<void> reboot(WebViewController controller);

  String get loginUrl;
}