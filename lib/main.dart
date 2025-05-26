import 'package:flutter/material.dart';
import 'package:router/abstractt.dart';
import 'package:router/model_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
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
  late WebViewController _controller;
  bool _showWebView = false;
  String _statusMessage = '';
  bool _isLoading = false;
  RouterStrategy? _selectedRouter;
  String? _selectedHuaweiOption;

  TextEditingController _usernamecontroller =  TextEditingController();
  TextEditingController _passoredcontroller =  TextEditingController();



  TextEditingController _wlSsidcontroller =  TextEditingController();
  TextEditingController _wlWpaPskcontroller =  TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Map<String, RouterStrategy> _routerStrategies = {
    'HUAWEI NE': HuaweiRouter(),
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

        await _selectedRouter!.lan(_controller);
        await Future.delayed(const Duration(seconds:15));
        await _selectedRouter!.wan(_controller ,_selectedHuaweiOption! , _usernamecontroller.text , _passoredcontroller.text);
        await Future.delayed(const Duration(seconds:23));
        await _selectedRouter!.changeWifiSettings(_controller ,_wlSsidcontroller.text , _wlWpaPskcontroller.text ,context );

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
              if (_statusMessage.isNotEmpty)
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

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.contains('خطأ') ? Colors.red : Colors.green,
                    ),
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
                      onChanged: (value) => setState(() {
                        _selectedRouter = value;
                      }),
                    )),
                    if (_selectedRouter is HuaweiRouter)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder()
                          ),
                          value: _selectedHuaweiOption,
                          hint: const Text('VLAN ID'),
                          items: const [
                            DropdownMenuItem(value: '1', child: Text('1')),
                            DropdownMenuItem(value: '2', child: Text('2')),
                            DropdownMenuItem(value: '0', child: Text('بدون')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedHuaweiOption = value;
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