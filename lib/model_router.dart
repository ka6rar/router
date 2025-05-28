import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'abstractt.dart';

class HuaweiRouter implements RouterStrategy {
  @override
  String get loginUrl => 'http://192.168.100.1/';

  // تحسينات عامة: إضافة تأخيرات أكثر ذكاءً وتحسين معالجة الأخطاء
  Future<void> _executeScriptWithRetry(
      WebViewController controller,
      String script, {
        int maxRetries = 3,
        int delayMs = 1000,
      }) async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        await controller.runJavaScript(script);
        return;
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
  }

  @override
  Future<void> login(WebViewController controller) async {
    const script = '''
    (async function() {
      function waitForElement(id, timeout = 10000) {
        return new Promise((resolve, reject) => {
          const start = Date.now();
          const timer = setInterval(() => {
            const el = document.getElementById(id);
            if (el) {
              clearInterval(timer);
              resolve(el);
            } else if (Date.now() - start > timeout) {
              clearInterval(timer);
              reject(new Error("Element not found: " + id));
            }
          }, 200);
        });
      }

      try {
        const usernameInput = await waitForElement("txt_Username");
        usernameInput.value = "telecomadmin";
        window.FlutterPostMessage.postMessage("username_done");

        const passwordInput = await waitForElement("txt_Password");
        passwordInput.value = "admintelecom";
        window.FlutterPostMessage.postMessage("password_done");

        const loginBtn = await waitForElement("loginbutton");
        loginBtn.click();
        window.FlutterPostMessage.postMessage("login_done");
      } catch (err) {
        console.error("Login error:", err);
        throw err;
      }
    })();
    ''';
    await _executeScriptWithRetry(controller, script);
  }

  @override
  Future<void> startCenter(WebViewController controller) async {
    const script = '''
    (async function() {
      function waitForClickable(id, timeout = 5000) {
        return new Promise((resolve, reject) => {
          const start = Date.now();
          const timer = setInterval(() => {
            const el = document.getElementById(id);
            if (el && !el.disabled) {
              clearInterval(timer);
              el.click();
              resolve();
            } else if (Date.now() - start > timeout) {
              clearInterval(timer);
              reject(new Error("Element not clickable: " + id));
            }
          }, 200);
        });
      }
      await waitForClickable("firstpage");
    })();
    ''';
    await _executeScriptWithRetry(controller, script);
  }

  @override
  Future<void> lan(WebViewController controller) async {
    const script = '''
  (async () => {
    function waitForElement(doc, id, timeout = 10000) {
      return new Promise((resolve, reject) => {
        const start = Date.now();
        const timer = setInterval(() => {
          const el = doc.getElementById(id);
          if (el) {
            clearInterval(timer);
            resolve(el);
          } else if (Date.now() - start > timeout) {
            clearInterval(timer);
            reject(new Error("Element not found: " + id));
          }
        }, 200);
      });
    }

    function waitForIframe(timeout = 10000) {
      return new Promise((resolve, reject) => {
        const start = Date.now();
        const timer = setInterval(() => {
          const iframe = document.querySelector("iframe");
          if (iframe && iframe.contentDocument && iframe.contentDocument.readyState === 'complete') {
            clearInterval(timer);
            resolve(iframe.contentDocument);
          } else if (Date.now() - start > timeout) {
            clearInterval(timer);
            reject(new Error("IFrame not fully loaded"));
          }
        }, 200);
      });
    }

    async function setupLanPort(doc, portId) {
      try {
        const checkbox = await waitForElement(doc, portId);
        if (!checkbox.checked) {
          checkbox.click();
          window.FlutterPostMessage.postMessage(portId);
        }
        await new Promise(resolve => setTimeout(resolve, 1000));
      } catch (e) {
        console.error("Error setting up port " + portId + ":", e);
        throw e;
      }
    }

    try {
      const configBtn = document.getElementById("name_lanconfig");
      if (configBtn) {
        configBtn.click();
        await new Promise(resolve => setTimeout(resolve, 1000));
      }

      const iframeDoc = await waitForIframe();
      await new Promise(resolve => setTimeout(resolve, 5000)); // تأخير قبل الضغط

      await setupLanPort(iframeDoc, "cb_Lan1");
      await setupLanPort(iframeDoc, "cb_Lan2");
      await setupLanPort(iframeDoc, "cb_Lan3");
      await setupLanPort(iframeDoc, "cb_Lan4");

      const applyBtn = await waitForElement(iframeDoc, "Apply");
      await new Promise(resolve => setTimeout(resolve, 1000));

      applyBtn.click();
      await new Promise(resolve => setTimeout(resolve, 2000));
    } catch (err) {
      console.error("LAN setup failed:", err);
      throw err;
    }
  })();
  ''';

    await _executeScriptWithRetry(controller, script);
  }

  @override
  Future<void> wan(WebViewController controller, String selectedHuaweiOption, String username, String password) async {
    final script = '''
    (async () => {
      function waitForElement(doc, id, timeout = 10000) {
        return new Promise((resolve, reject) => {
          const start = Date.now();
          const timer = setInterval(() => {
            const el = doc.getElementById(id);
            if (el) {
              clearInterval(timer);
              resolve(el);
            } else if (Date.now() - start > timeout) {
              clearInterval(timer);
              reject(new Error("Element not found: " + id));
            }
          }, 200);
        });
      }

      function waitForIframe(timeout = 15000) {
        return new Promise((resolve, reject) => {
          const start = Date.now();
          const timer = setInterval(() => {
            const iframe = document.querySelector("iframe");
            if (iframe && iframe.contentDocument) {
              clearInterval(timer);
              resolve(iframe.contentDocument);
            } else if (Date.now() - start > timeout) {
              clearInterval(timer);
              reject(new Error("iframe لم يظهر بعد إعادة التحميل"));
            }
          }, 300);
        });
      }

      try {
        document.getElementById("name_wanconfig").click();
        await new Promise(resolve => setTimeout(resolve, 2000));

        let iframe = document.querySelector("iframe");
        if (!iframe || !iframe.contentDocument) {
          throw new Error("IFrame not accessible");
        }

        let iframeDoc = iframe.contentDocument;
        await new Promise(resolve => setTimeout(resolve, 3000));

        const wanIds = [
          "wanInstTable_rml0",
          "wanInstTable_rml1",
          "wanInstTable_rml2",
          "wanInstTable_rml3",
          "wanInstTable_rml4",
          "wanInstTable_rml5",
          "wanInstTable_rml6",
          "wanInstTable_rml7"
        ];

        let selectedCount = 0;

        for (const id of wanIds) {
          const el = iframeDoc.getElementById(id);
          if (el) {
            el.click();
            selectedCount++;
            await new Promise(resolve => setTimeout(resolve, 600));
          }
        }

        if (selectedCount > 0) {
          const deleteBtn = iframeDoc.getElementById("DeleteButton");
          if (deleteBtn) {
            deleteBtn.click();
            console.log("تم الضغط على زر الحذف");
            await new Promise(resolve => setTimeout(resolve, 5000));
          }

          // إعادة تحميل إعدادات WAN يدويًا
          document.getElementById("name_wanconfig").click();
          await new Promise(resolve => setTimeout(resolve, 5000));

          iframe = document.querySelector("iframe");
          iframeDoc = iframe.contentDocument;
        }

        // زر Newbutton بعد الحذف
        const newBtn = await waitForElement(iframeDoc, "Newbutton");
        newBtn.click();
        await new Promise(resolve => setTimeout(resolve, 3000));

        const encapMode = await waitForElement(iframeDoc, "EncapMode2");
        if (!encapMode.checked) {
          encapMode.click();
          window.FlutterPostMessage.postMessage("EncapMode2");
        }
        await new Promise(resolve => setTimeout(resolve, 1000));

        if ("${selectedHuaweiOption}" === "0") {
          const vlanSwitch = await waitForElement(iframeDoc, "VlanSwitch");
          vlanSwitch.click();
          window.FlutterPostMessage.postMessage("VlanSwitch");
        } else {
          const vlanId = await waitForElement(iframeDoc, "VlanId");
          vlanId.value = "${selectedHuaweiOption}";
          window.FlutterPostMessage.postMessage("VlanId${selectedHuaweiOption}");
        }
        await new Promise(resolve => setTimeout(resolve, 1000));

        const userName = await waitForElement(iframeDoc, "UserName");
        userName.value = "${username}";
        window.FlutterPostMessage.postMessage("UserName");
        await new Promise(resolve => setTimeout(resolve, 1000));

        const passInput = await waitForElement(iframeDoc, "Password");
        passInput.value = "${password}";
        window.FlutterPostMessage.postMessage("Password");
        await new Promise(resolve => setTimeout(resolve, 1000));

        const applyBtn = await waitForElement(iframeDoc, "ButtonApply");
        applyBtn.click();
        await new Promise(resolve => setTimeout(resolve, 4000));

      } catch (err) {
        console.error("WAN setup failed:", err);
        throw err;
      }
    })();
  ''';
    await _executeScriptWithRetry(controller, script);
  }

  @override
  Future<void> changeWifiSettings(WebViewController controller, String wlSsid, String wlWpaPsk) async {
    final script = '''
    (async () => {
      function waitForElement(doc, id, timeout = 15000) {
        return new Promise((resolve, reject) => {
          const start = Date.now();
          const timer = setInterval(() => {
            const el = doc.getElementById(id);
            if (el) {
              clearInterval(timer);
              resolve(el);
            } else if (Date.now() - start > timeout) {
              clearInterval(timer);
              reject(new Error("Element not found: " + id));
            }
          }, 300);
        });
      }

      try {
        document.getElementById("name_wlanconfig").click();
        await new Promise(resolve => setTimeout(resolve, 2000));

        const iframe = document.querySelector("iframe");
        if (!iframe || !iframe.contentDocument) {
          throw new Error("IFrame not accessible");
        }

        const iframeDoc = iframe.contentDocument;
        await new Promise(resolve => setTimeout(resolve, 4000));

        // تغيير اسم الشبكة
        const ssidInput = await waitForElement(iframeDoc, "wlSsid");
        ssidInput.value = "${wlSsid}";
        await new Promise(resolve => setTimeout(resolve, 1000));

        // تغيير كلمة المرور
        const passInput = await waitForElement(iframeDoc, "wlWpaPsk");
        passInput.value = "${wlWpaPsk}";
        await new Promise(resolve => setTimeout(resolve, 1000));

        // تطبيق التغييرات
        const applyBtn = await waitForElement(iframeDoc, "btnApplySubmit"); 
        applyBtn.click();
        await new Promise(resolve => setTimeout(resolve, 3000));

        window.FlutterPostMessage.postMessage("wifiChanged");
      } catch (err) {
        console.error("WiFi setup failed:", err);
        throw err;
      }
    })();
    ''';
    await _executeScriptWithRetry(controller, script);
  }

  @override
  Future<void> reboot(WebViewController controller) async {
    // يمكن تنفيذ إعادة التشغيل هنا إذا لزم الأمر
  }
}