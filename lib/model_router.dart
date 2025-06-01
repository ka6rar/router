import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'abstractt.dart';

class HuaweiRouterNew implements RouterStrategy {
  @override

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

        const passwordInput = await waitForElement("txt_Password");
        passwordInput.value = "admintelecom";

        const loginBtn = await waitForElement("loginbutton");
        
       loginBtn.addEventListener('click', () => {
        window.FlutterPostMessage.postMessage("login");
       });
       loginBtn.click();
    
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
    applyBtn.addEventListener('click', () => {
      window.FlutterPostMessage.postMessage("portId");
    });
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

  Future<void> ontAuth(WebViewController controller, String notAuth) async {
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

    // ⬅️ الضغط على عنصر "ONT Authentication"
    const divs = document.querySelectorAll("div");
    for (let div of divs) {
      if (div.textContent.trim() === "ONT Authentication") {
        div.click();
        break;
      }
    }

    try {
      await new Promise(resolve => setTimeout(resolve, 3000));

      const iframe = document.querySelector("iframe");
      if (iframe && iframe.contentDocument && iframe.contentWindow) {
        const doc = iframe.contentDocument;
  
        await new Promise(resolve => setTimeout(resolve, 1000));

        // تعبئة SNValue داخل iframe
        const SNValue = await waitForElement(doc, "SNValue");
        SNValue.value = "";
        SNValue.value = "$notAuth";

        await new Promise(resolve => setTimeout(resolve, 1000));

        // ✅ الضغط على الزر من داخل doc (وليس document الخارجي)
        const btnApply_ex2 = await waitForElement(doc, "btnApply_ex2");
        btnApply_ex2.setAttribute("type", "button"); // يمنع submit
        btnApply_ex2.click();

      } else {
        console.error("❌ iframe غير موجود أو لا يمكن الوصول إليه");
      }
    } catch (e) {
      console.error("❌ حدث خطأ:", e);
    }
  })();
  ''';
    await _executeScriptWithRetry(controller, script);
  }

  @override
  Future<void> wan(WebViewController controller, String vlan, String username,
      String password) async {
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

        if ("$vlan" === "0") {
          const vlanSwitch = await waitForElement(iframeDoc, "VlanSwitch");
          vlanSwitch.click();
          window.FlutterPostMessage.postMessage("VlanSwitch");
        } else {
          const vlanId = await waitForElement(iframeDoc, "VlanId");
          vlanId.value = "$vlan";
          window.FlutterPostMessage.postMessage("VlanId$vlan");
        }
        await new Promise(resolve => setTimeout(resolve, 1000));

        const userName = await waitForElement(iframeDoc, "UserName");
        userName.value = "$username";
        window.FlutterPostMessage.postMessage("UserName");
        await new Promise(resolve => setTimeout(resolve, 1000));

        const passInput = await waitForElement(iframeDoc, "Password");
        passInput.value = "$password";
        window.FlutterPostMessage.postMessage("Password");
        await new Promise(resolve => setTimeout(resolve, 1000));

        const applyBtn = await waitForElement(iframeDoc, "ButtonApply");
       applyBtn.addEventListener('click', () => {
        window.FlutterPostMessage.postMessage("wan");
       });
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
  Future<void> changeWifiSettings(
      WebViewController controller, String wlSsid, String wlWpaPsk) async {
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
        ssidInput.value = "$wlSsid";
        await new Promise(resolve => setTimeout(resolve, 1000));

        // تغيير كلمة المرور
        const passInput = await waitForElement(iframeDoc, "wlWpaPsk");
        passInput.value = "$wlWpaPsk";
        await new Promise(resolve => setTimeout(resolve, 1000));

        
        const applyBtn = await waitForElement(iframeDoc, "btnApplySubmit");
       applyBtn.addEventListener('click', () => {
        window.FlutterPostMessage.postMessage("WifiSettings");
       });
       applyBtn.click();
       
        await new Promise(resolve => setTimeout(resolve, 3000));

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
    await controller.clearLocalStorage();
    await controller.clearCache();
  }
}






































class HuaweiRouterOld implements RouterStrategy {
  @override

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

        const passwordInput = await waitForElement("txt_Password");
        passwordInput.value = "admintelecom";

        const loginBtn = await waitForElement("button");
        
       loginBtn.addEventListener('click', () => {
        window.FlutterPostMessage.postMessage("login");
       });
       loginBtn.click();
    
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

        const divs = document.querySelectorAll("div");
          for (let div of divs) {
            if (div.textContent.trim() === "LAN") {
              div.click();
              break;
            }
          }
      
        const iframe = document.querySelector("iframe");
        if (iframe && iframe.contentDocument) {
         const doc = iframe.contentDocument;
      
        const lanLabels = ["LAN1", "LAN2", "LAN3", "LAN4"];
      
        for (let label of lanLabels) {
          const div = Array.from(doc.querySelectorAll("div")).find(d =>
            d.textContent.includes(label)
          );
      
          if (div) {
            const checkbox = div.querySelector("input[type='checkbox']");
            if (checkbox) {
              checkbox.checked = true; // تفعيل checkbox
              checkbox.dispatchEvent(new Event("change"));
              console.log(`✅ تم تفعيل  داخل iframe`);
            }
          }
        }
      
        const Apply = await waitForElement(doc, "Apply");
        if (Apply) {
          Apply.click();
          console.log("✅ تم الضغط على زر Apply داخل iframe");
           if (window.FlutterPostMessage?.postMessage) {
                window.FlutterPostMessage.postMessage("portId");
              }
        } else {
          console.log("❌ لم يتم العثور على زر Apply داخل iframe");
        }
      } else {
        console.log("❌ لم يتم العثور على iframe أو لا يمكن الوصول إليه");
      }

     
     
     

  })();
  ''';

    await _executeScriptWithRetry(controller, script);
  }


  Future<void> ontAuth(WebViewController controller, String notAuth) async {
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

  // النقر على System Tools
  const divs = document.querySelectorAll("div");
  for (let div of divs) {
    if (div.textContent.trim() === "System Tools") {
      div.click();
      break;
    }
  }

  // النقر على ONT Authentication
  const divss = document.querySelectorAll("div");
  for (let div of divss) {
    if (div.textContent.trim() === "ONT Authentication") {
      div.click();
      break;
    }
  }

  try {
    // انتظار قليل لتحميل المحتوى
    await new Promise(resolve => setTimeout(resolve, 2000));

    const iframes = document.querySelectorAll("iframe");
    let found = false;

    for (let iframe of iframes) {
      try {
        console.log("📄 محاولة الوصول إلى iframe:", iframe.src || "[no src]");

        const doc = iframe.contentDocument;
        if (!doc) {
          console.warn("⚠️ لا يمكن الوصول إلى contentDocument لهذا iframe.");
          continue;
        }

        // انتظار العناصر داخل iframe
        const SNValue = await waitForElement(doc, "SNValue", 5000);
        SNValue.value = "";
        SNValue.value = "$notAuth";

        await new Promise(resolve => setTimeout(resolve, 500));

        const btnApply_ex2 = await waitForElement(doc, "btnApply_ex2", 5000);
        btnApply_ex2.setAttribute("type", "button");
        btnApply_ex2.click();

        console.log("✅ تم الضغط على الزر وتعبئة القيمة.");
        found = true;
        break;
      } catch (err) {
        console.warn("❌ لم يتم العثور على العنصر في هذا iframe:", err.message);
      }
    }

    if (!found) {
      console.error("❌ لم يتم العثور على SNValue في أي iframe");
    }
  } catch (e) {
    console.error("❌ حدث خطأ عام:", e);
  }
})();
''';

    await _executeScriptWithRetry(controller, script);
  }

  @override
  Future<void> wan(WebViewController controller, String vlan, String username, String password) async {
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

    const divs = document.querySelectorAll("div");
    for (let div of divs) {
      if (div.textContent.trim() === "WAN") {
        div.click();
        break;
      }
    }

    await new Promise(resolve => setTimeout(resolve, 1000)); // مهلة بسيطة لدخول الـ iframe

    const iframe = document.querySelector("iframe");
    if (iframe && iframe.contentWindow && iframe.contentDocument) {
      const doc = iframe.contentDocument;

      const Apply = await waitForElement(doc, "Newbutton");
      Apply.click();
      await new Promise(resolve => setTimeout(resolve, 3000));

      const encapMode = await waitForElement(doc, "EncapMode2");
      if (!encapMode.checked) {
        encapMode.click();
      }
      
      await new Promise(resolve => setTimeout(resolve, 1000));

      if ("$vlan" === "0") {
        const vlanSwitchd = await waitForElement(doc, "VlanSwitch");
        if (vlanSwitchd.checked) {
          vlanSwitchd.click();
          window.FlutterPostMessage.postMessage("VlanSwitch Enabled");
        } else {
          window.FlutterPostMessage.postMessage("VlanSwitch Already Enabled");
        }
      } else {
        const vlanIds = await waitForElement(doc, "VlanId");
        vlanIds.value = "$vlan";
        window.FlutterPostMessage.postMessage("VlanId set");
      }

      await new Promise(resolve => setTimeout(resolve, 1000));

      const userName = await waitForElement(doc, "UserName");
      userName.value = "$username";
      window.FlutterPostMessage.postMessage("UserName");
      await new Promise(resolve => setTimeout(resolve, 1000));

      const passInput = await waitForElement(doc, "Password");
      passInput.value = "$password";
      await new Promise(resolve => setTimeout(resolve, 1000));

      const applyBtn = await waitForElement(doc, "ButtonApply");
      applyBtn.addEventListener('click', () => {
        window.FlutterPostMessage.postMessage("wan");
      });
      applyBtn.click();

      await new Promise(resolve => setTimeout(resolve, 4000));
    } else {
      window.FlutterPostMessage.postMessage("❌ iframe not found or inaccessible");
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

    const divs = document.querySelectorAll("div");
    for (let div of divs) {
      if (div.textContent.trim() === "WLAN") {
        div.click();
        break;
      }
    }

    const iframe = document.querySelector("iframe");
    if (iframe && iframe.contentWindow && iframe.contentDocument) {
      const doc = iframe.contentDocument;
      await new Promise(resolve => setTimeout(resolve, 4000));

      // تغيير اسم الشبكة
      const ssidInput = await waitForElement(doc, "wlSsid");
      ssidInput.value = "$wlSsid";
      await new Promise(resolve => setTimeout(resolve, 1000));

      // تغيير كلمة المرور
      const passInput = await waitForElement(doc, "wlWpaPsk");
      passInput.value = "$wlWpaPsk";
      await new Promise(resolve => setTimeout(resolve, 1000));

      const applyBtn = await waitForElement(doc, "btnApplySubmit");
      applyBtn.addEventListener('click', () => {
        window.FlutterPostMessage.postMessage("WifiSettings");
      });
      applyBtn.click();

      await new Promise(resolve => setTimeout(resolve, 3000));
    }
  })();
  ''';

    await _executeScriptWithRetry(controller, script);
  }


  @override
  Future<void> reboot(WebViewController controller) async {
    await controller.clearLocalStorage();
    await controller.clearCache();
  }
}


