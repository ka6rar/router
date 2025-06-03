import 'package:app_links/app_links.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

Future<void> deepLink({
  required AppLinks appLinks,
  required TextEditingController wlSsidController,
  required TextEditingController wlWpaPskController,
  required TextEditingController usernameController,
  required TextEditingController passwordController,
  required List<Map<String, dynamic>> vlanList,
  required Map<String, dynamic> routerStrategies,
  required Function(String) onVlanChanged,
  required Function(dynamic) onRouterChanged,
  required Function(bool) onRouterOnt,
  required Map<String, bool> routeront,
  required TextEditingController ontAuthcationController,
}) async {

  // 🔍 أولاً نبحث عن الرابط من Firebase Dynamic Links
  final PendingDynamicLinkData? initialDynamicLink =
  await FirebaseDynamicLinks.instance.getInitialLink();
  Uri? uri = initialDynamicLink?.link;

  // إذا لم يوجد، نستخدم AppLinks
  uri ??= await appLinks.getInitialLink();

  if (uri != null) {
    print('Received deep link: $uri');

    // 🧠 معالجة الرابط
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

    if (uri.queryParameters['vlan'] != null &&
        vlanList.any((item) => item['value'] == uri!.queryParameters['vlan'])) {
      onVlanChanged(uri.queryParameters['vlan']!);
    }

    if (uri.queryParameters['typeRouter'] != null &&
        routerStrategies.containsKey(uri.queryParameters['typeRouter'])) {
      onRouterChanged(routerStrategies[uri.queryParameters['typeRouter']!]);
    }

    final ontParam = uri.queryParameters['ont'];
    if (ontParam != null && routeront.containsKey(ontParam)) {
      onRouterOnt(routeront[ontParam]!);
    }

    if (uri.queryParameters['ont_text'] != null) {
      ontAuthcationController.text = uri.queryParameters['ont_text']!;
    }
  } else {
    print('No deep link found');
  }
}
