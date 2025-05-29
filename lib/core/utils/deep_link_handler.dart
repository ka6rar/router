import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

Future<void> deepLink({
  required AppLinks appLinks,
  required TextEditingController wlSsidController,
  required TextEditingController wlWpaPskController,
  required TextEditingController usernameController,
  required TextEditingController passwordController,
  required List<Map<String, dynamic>> vlanList,
  required Map<String, dynamic> routerStrategies,
  required Function(String) onVlanChanged, // Callback لتحديث VLAN
  required Function(dynamic) onRouterChanged, // Callback لتحديث Router
}) async {
  final uri = await appLinks.getInitialLink();

  if (uri != null) {
    // تحديث حقول النص
    if (uri.queryParameters['name_r'] != null) {
      wlSsidController.text = uri.queryParameters['name_r']!;
    }
    if (uri.queryParameters['password_r'] != null) {
      wlWpaPskController.text = uri.queryParameters['password_r']!;
    }
    if (uri.queryParameters['username'] != null) {
      usernameController.text = uri.queryParameters['username']!;
    }
    if (uri.queryParameters['password'] != null) {
      passwordController.text = uri.queryParameters['password']!;
    }

    // تحديث VLAN (باستخدام callback)
    if (uri.queryParameters['vlan'] != null &&
        vlanList.any((item) => item['value'] == uri.queryParameters['vlan'])) {
      onVlanChanged(uri.queryParameters['vlan']!);
    }

    // تحديث Router (باستخدام callback)
    if (uri.queryParameters['typeRouter'] != null &&
        routerStrategies.containsKey(uri.queryParameters['typeRouter'])) {
      onRouterChanged(routerStrategies[uri.queryParameters['typeRouter']!]);
    }
  }
}