import 'package:webview_flutter/webview_flutter.dart';

Future<void> waitUntilReady(String elementId, {int timeoutMs = 10000, required WebViewController controller}) async {
  try {
    await controller.runJavaScriptReturningResult('''
      new Promise((resolve, reject) => {
        const start = Date.now();
        const timer = setInterval(() => {
          if (document.getElementById("$elementId")) {
            clearInterval(timer);
            resolve(true);
          } else if (Date.now() - start > $timeoutMs) {
            clearInterval(timer);
            reject("Timeout waiting for $elementId");
          }
        }, 300);
      });
    ''');
  } catch (e) {
    print("Error waiting for element $elementId: $e");
    rethrow;
  }
}
