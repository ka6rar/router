import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:router/abstractt.dart';
import 'package:router/model_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: AutoRouterLogin(),
    debugShowCheckedModeBanner: false,
  ));
}

class AutoRouterLogin extends StatefulWidget {
  const AutoRouterLogin({Key? key}) : super(key: key);

  @override
  _AutoRouterLoginState createState() => _AutoRouterLoginState();
}

class _AutoRouterLoginState extends State<AutoRouterLogin> {

  String ipAddress = 'جارٍ التحميل...';
  late  StreamSubscription<ConnectivityResult> _subscription;

  late WebViewController _controller;
  bool _showWebView = false;
  String _statusMessage = '';
  bool _isLoading = false;
  RouterStrategy? _selectedRouter;
  String? _selectedHuaweiOption;

  TextEditingController _usernamecontroller =  TextEditingController();
  TextEditingController _passoredcontroller =  TextEditingController();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final AppLinks _appLinks = AppLinks();
  String? selectedVlan;

  List<Map<String, String>> vlanlist = [
    {
      "name": "1",
      "value": "1"
    },
    {
      "name": "2",
      "value": "2"
    },
    {
      "name": "لا يوجد",
      "value": "0"
    }
  ];


  Future<void> _handleInitialUri() async {
    final uri = await _appLinks.getInitialLink();
    if (uri != null) {
      final name_r = uri.queryParameters['name_r'];
      final password_r = uri.queryParameters['password_r'];


      if (name_r != null) _wlSsidcontroller.text = name_r;
      if (password_r != null) _wlWpaPskcontroller.text = password_r;

      final username = uri.queryParameters['username'];
      final password = uri.queryParameters['password'];


      if (username != null) _usernamecontroller.text = username;
      if (password != null) _passoredcontroller.text = password;

      final vlan = uri.queryParameters['vlan'];
      if (vlan != null &&  vlanlist.any((item) => item['value'] == vlan)) {
        setState(() {
          selectedVlan = vlan;
        });
      }

      final selectedHuaweiOption = uri.queryParameters['typeRouter'];

      if (selectedHuaweiOption != null &&
          _routerStrategies.containsKey(selectedHuaweiOption)) {
        setState(() {
          _selectedRouter = _routerStrategies[selectedHuaweiOption];
        });
      }


    }
  }

  @override
  void initState() {
    super.initState();
    _updateIP();
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        final name = uri.queryParameters['name'];
        final code = uri.queryParameters['code'];

        if (name != null) _usernamecontroller.text = name;
        if (code != null) _passoredcontroller.text = code;
      }
    });

    _connectivitySubscription =  _connectivity.onConnectivityChanged.listen((event) {
          _updateIP();
        },);
    // Also handle app start via a link
    _handleInitialUri();
  }


  Future<void> _updateIP() async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

    final info = NetworkInfo();
       if (connectivityResult.contains(ConnectivityResult.wifi)) {
             String? ip;
             ip = await info.getWifiGatewayIP();
             ipAddress = ip ?? 'لم يتم العثور على ';
             setState(() {
               _statusMessage = ip.toString();
             });

      }  else {
          ipAddress = "يدعم فقط الرواتر";
          setState(() {
            _statusMessage = ipAddress;
          });
       }
    if (connectivityResult.contains(ConnectivityResult.none)) {
       ipAddress =  "الواي فاي معطل ";
       setState(() {
         _statusMessage = ipAddress;
       });

    }

  }



  TextEditingController _wlSsidcontroller =  TextEditingController();
  TextEditingController _wlWpaPskcontroller =  TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Map<String, RouterStrategy> _routerStrategies = {
    'HUAWEI': HuaweiRouter(),
    // يمكن إضافة المزيد هنا
  };

  Future<void> runRouterAuth() async {

    if(_formKey.currentState!.validate()) {



      if (_selectedRouter == null) {
        setState(() => _statusMessage = 'الرجاء اختيار نوع الراوتر');
        return;
      }
      if (_selectedHuaweiOption == null) {
        setState(() => _statusMessage = "  VL1 و VL2 اختار نواع");
        return;
      }

      setState(() {
        _isLoading = true;
        _statusMessage = 'جاري الاتصال بالراوتر...';
      });

      try {
        _controller = WebViewController()
          ..addJavaScriptChannel(
            'FlutterPostMessage',
            onMessageReceived: (message) {
              if (message.message == 'wifiChanged') {
                setState(() {
                  _showWebView = false;
                  _statusMessage = 'تم تغيير إعدادات الواي فاي بنجاح!';
                  _controller.clearCache();
                  _controller.clearLocalStorage();

                });
              }
            },
          )
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) => setState(() => _statusMessage = 'جاري التحميل...'),
              onPageFinished: (url) async => await _handleRouterFlow(),
              onWebResourceError: (error) => setState(() {
                _statusMessage = 'خطأ في التحميل: ${error.description}';
                _isLoading = false;
              }),
            ),
          )
          ..loadRequest(Uri.parse(_selectedRouter!.loginUrl));

        setState(() {
          _showWebView = true;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _statusMessage = 'خطأ في الاتصال: $e';
          _isLoading = false;
        });
      }
    }
  }
  Future<void> _handleRouterFlow() async {
    try {
      await _selectedRouter!.login(_controller);
      setState(() => _statusMessage = 'تم التسجيل بنجاح');
      await Future.delayed(const Duration(seconds:3));
      await _selectedRouter!.startCenter(_controller);
      await Future.delayed(const Duration(seconds:3));
      await _selectedRouter!.lan(_controller);
      await Future.delayed(const Duration(seconds:33));
      await _selectedRouter!.wan(_controller ,_selectedHuaweiOption! , _usernamecontroller.text , _passoredcontroller.text);
      await Future.delayed(const Duration(seconds:34));
      await _selectedRouter!.changeWifiSettings(_controller ,_wlSsidcontroller.text , _wlWpaPskcontroller.text  );

    } catch (e) {
      setState(() => _statusMessage = 'خطأ: ${e.toString()}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الراوتر')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (_statusMessage.isNotEmpty && ipAddress.isEmpty)
                GestureDetector(
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AutoRouterLogin())
                    );
                    _controller.clearCache();
                    _controller.clearLocalStorage();

                  },
                  child: const Text('نهاء'),
                ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('خطأ') ? Colors.red.shade800 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      _statusMessage.contains('خطأ') ? Icons.close_rounded : Icons.check_rounded,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _showWebView
                    ? WebViewWidget(controller: _controller)
                    : ListView(

                  children: [
                    SizedBox(
                      height: 100,
                      width: double.infinity, // أو استخدم عرض مناسب أكبر من 100
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال اسم الشبكة';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: 'أسم الشبكة',
                                border: OutlineInputBorder(),
                              ),
                              controller: _wlSsidcontroller,
                            ),
                          ),
                          const SizedBox(width: 10), // مسافة بين الحقول
                          Expanded(
                            child: TextFormField(
                              controller: _wlWpaPskcontroller,
                              decoration: const InputDecoration(
                                hintText: 'رمز الراوتر',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال رمز الراوتر';
                                }
                                if (value.length < 8) {
                                  return 'يجب أن يحتوي الرمز على 8 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),
                          ),

                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      width: double.infinity, // أو استخدم عرض مناسب أكبر من 100
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _usernamecontroller,
                              decoration: const InputDecoration(
                                hintText: 'Username', // ← تم تصحيح الكلمة من "Uaername" إلى "Username"
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال اسم المستخدم';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10), // مسافة بين الحقول
                          Expanded(
                            child: TextFormField(
                              controller: _passoredcontroller, // ← تأكد من صحة الاسم
                              decoration: const InputDecoration(
                                hintText: 'Password',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور';
                                }
                                return null;
                              },
                            ),

                          ),

                        ],
                      ),
                    ),

                    ..._routerStrategies.entries.map((entry) => RadioListTile(
                      title: Text(entry.key),
                      value: entry.value,
                      groupValue: _selectedRouter,
                      onChanged: (value) {
                        setState(() {
                          _selectedRouter = value;
                        });
                      },
                    )),

                    if (_selectedRouter is HuaweiRouter)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                              border: OutlineInputBorder()
                          ),
                          value: selectedVlan,
                          hint: const Text('VLAN ID'),
                          items: vlanlist.map((code) {
                            return DropdownMenuItem(
                              value: code['value'],
                              child: Text(code['name']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedVlan = value;
                            });
                          },
                        ),
                      ),

                    ElevatedButton(
                      onPressed: _isLoading ? null : runRouterAuth,
                      child: const Text('اتصال'),
                    ),
                    if (_isLoading) const CircularProgressIndicator(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}