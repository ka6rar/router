import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:router/main.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'abstractt.dart';

class HuaweiRouter implements RouterStrategy {
  @override
  String get loginUrl => 'http://192.168.100.1/';
  @override

  Future<void> login(WebViewController controller ) async {
    await controller.runJavaScript('''
      document.getElementById("txt_Username").value = "telecomadmin";
      document.getElementById("txt_Password").value = "admintelecom";
      document.getElementById("loginbutton").click();
    ''');
  }


  Future<void> wan(WebViewController controller, String selectedHuaweiOption     , String username , String password) async {
    await controller.runJavaScript('''
    (async () => {
      const selectedHuaweiOption = "${selectedHuaweiOption}"; 

      const btnConfig = document.getElementById("name_wanconfig");
      if (btnConfig) {
        btnConfig.click();
      }

      await new Promise(resolve => setTimeout(resolve, 1500));
      const iframe = document.querySelector("iframe");

      if (iframe && iframe.contentWindow && iframe.contentDocument) {

        function waitForElementInIframe(doc, id, timeout = 5000) {
          return new Promise((resolve, reject) => {
            const start = Date.now();
            const timer = setInterval(() => {
              const el = doc.getElementById(id);
              if (el) {
                clearInterval(timer);
                resolve(el);
              } else if (Date.now() - start > timeout) {
                clearInterval(timer);
                reject("Timeout waiting for element in iframe: " + id);
              }
            }, 100);
          });
        }

        function sleep(ms) {
          return new Promise(resolve => setTimeout(resolve, ms));
        }

        try {
          const iframeDoc = iframe.contentDocument;

          const newBtn = await waitForElementInIframe(iframeDoc, "Newbutton");
          newBtn.click();
          await sleep(3000);

          const checkbox = await waitForElementInIframe(iframeDoc, "EncapMode2");
          if (!checkbox.checked) {
            checkbox.click(); 
          }

          await sleep(3000);

          if (selectedHuaweiOption === "0") {
              const VlanSwitch = await waitForElementInIframe(iframeDoc, "VlanSwitch");
              VlanSwitch.click(); 
          } else if (selectedHuaweiOption === "1") 
          {
            const VlanId = await waitForElementInIframe(iframe.contentDocument, "VlanId");
            VlanId.value = "1";
          } else if (selectedHuaweiOption === "2") 
          {
            const VlanId = await waitForElementInIframe(iframe.contentDocument, "VlanId");
            VlanId.value = "2";
          }
          
          await sleep(3000);
          const UserName = await waitForElementInIframe(iframe.contentDocument, "UserName");
          UserName.value = "";
          UserName.value = "$username";

          await sleep(1000);

          const password = await waitForElementInIframe(iframe.contentDocument, "Password");
          password.value = "";
          password.value = "$password";
          
         await sleep(1000);
         
         
        const ButtonApply = await waitForElementInIframe(iframe.contentDocument, "ButtonApply");
        ButtonApply.click();
        
        await sleep(4000);
        
        
        } catch (err) {
          console.error(err);
        }

      } else {
        console.error("لم يتم العثور على iframe أو لا يمكن الوصول إلى محتواه.");
      }
    })();
  ''');
  }


  Future<void> lan(WebViewController controller) async {
    await controller.runJavaScript('''
    (async () => {

      const name_lanconfig = document.getElementById("name_lanconfig");
      if (name_lanconfig) {
        name_lanconfig.click();
      }

      await new Promise(resolve => setTimeout(resolve, 1500));
      const iframe = document.querySelector("iframe");

      if (iframe && iframe.contentWindow && iframe.contentDocument) {

        function waitForElementInIframe(doc, id, timeout = 5000) {
          return new Promise((resolve, reject) => {
            const start = Date.now();
            const timer = setInterval(() => {
              const el = doc.getElementById(id);
              if (el) {
                clearInterval(timer);
                resolve(el);
              } else if (Date.now() - start > timeout) {
                clearInterval(timer);
                reject("Timeout waiting for element in iframe: " + id);
              }
            }, 100);
          });
        }

        function sleep(ms) {
          return new Promise(resolve => setTimeout(resolve, ms));
        }

        try {
          const iframeDoc = iframe.contentDocument;

          await sleep(3000);

          const cb_Lan1 = await waitForElementInIframe(iframeDoc, "cb_Lan1");
          cb_Lan1.click(); 
          
          const cb_Lan2 = await waitForElementInIframe(iframeDoc, "cb_Lan2");
          cb_Lan2.click(); 
          
          const cb_Lan3 = await waitForElementInIframe(iframeDoc, "cb_Lan3");
          cb_Lan3.click(); 
          
          const cb_Lan4 = await waitForElementInIframe(iframeDoc, "cb_Lan4");
          cb_Lan4.click(); 
          
          await sleep(1000);
         
          const ButtonApply = await waitForElementInIframe(iframe.contentDocument, "Apply");
          ButtonApply.click();
        
        await sleep(4000);
        
        
        } catch (err) {
          console.error(err);
        }

      } else {
        console.error("لم يتم العثور على iframe أو لا يمكن الوصول إلى محتواه.");
      }
    })();
  ''');
  }

  @override
  Future<void> changeWifiSettings(WebViewController controller , String wlSsid , String wlWpaPsk ,context) async {
    await controller.runJavaScript('''
   (async () => {
    // اضغط أولاً على الزر الذي يفتح iframe أو يظهره
    document.getElementById("name_wlanconfig").click();

    // انتظر قليلاً حتى يتم تحميل iframe
    await new Promise(resolve => setTimeout(resolve, 1000));

    // الوصول إلى iframe (غيّر ID إذا لزم الأمر)
    const iframe = document.querySelector("iframe");

    if (iframe && iframe.contentDocument) {
      // انتظر حتى يظهر العنصر داخل iframe
      function waitForElementInIframe(doc, id, timeout = 5000) {
        return new Promise((resolve, reject) => {
          const start = Date.now();
          const timer = setInterval(() => {
            const el = doc.getElementById(id);
            if (el) {
              clearInterval(timer);
              resolve(el);
            } else if (Date.now() - start > timeout) {
              clearInterval(timer);
              reject("Timeout waiting for element in iframe: " + id);
            }
          }, 100);
        });
      }

      try {
        const wlSsid = await waitForElementInIframe(iframe.contentDocument, "wlSsid");
        wlSsid.value = "";
        wlSsid.value = "$wlSsid";
        
        const wlWpaPsk = await waitForElementInIframe(iframe.contentDocument, "wlWpaPsk");
        wlWpaPsk.value = "";
        wlWpaPsk.value = "$wlWpaPsk";
        
        function sleep(ms) {
          return new Promise(resolve => setTimeout(resolve, ms));
        }

        await sleep(2000);

        const button = await waitForElementInIframe(iframe.contentDocument, "btnApplySubmit");
        button.click();
       
         await sleep(1000); // ممكن تأخير بسيط قبل الإرسال

         window.FlutterPostMessage.postMessage("wifiChanged");

      } catch (err) {
        console.error(err);
      }
    } else {
      console.error("لم يتم العثور على iframe أو لا يمكن الوصول إلى محتواه.");
    }
  })();
''');


  }

  @override
  Future<void> reboot(WebViewController controller ,context) async {

  }


}

