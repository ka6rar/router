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

  TextEditingController _usernamecontroller =  TextEditingController();
  TextEditingController _passoredcontroller =  TextEditingController();



  TextEditingController _wlSsidcontroller =  TextEditingController();
  TextEditingController _wlWpaPskcontroller =  TextEditingController();

  final Map<String, RouterStrategy> _routerStrategies = {
    'HUAWEI NE': HuaweiRouter(),
    // يمكن إضافة المزيد هنا
  };

  Future<void> runRouterAuth() async {
    if (_selectedRouter == null) {
      setState(() => _statusMessage = 'الرجاء اختيار نوع الراوتر');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري الاتصال بالراوتر...';
    });

    try {
      _controller = WebViewController()
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
  Future<void> _handleRouterFlow() async {
    try {
      await _selectedRouter!.login(_controller,
       _usernamecontroller.text  ,
       _passoredcontroller.text  ,

      );
      setState(() => _statusMessage = 'تم التسجيل بنجاح');

      await _selectedRouter!.changeWifiSettings(_controller ,_wlSsidcontroller.text , _wlWpaPskcontroller.text );
      await Future.delayed(Duration(seconds: 10));
      await _selectedRouter!.wan(_controller ,_selectedHuaweiOption!);

      // يمكن استدعاء أي وظيفة أخرى حسب النوع
    } catch (e) {
      setState(() => _statusMessage = 'خطأ: ${e.toString()}');
    }
  }
  String? _selectedHuaweiOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الراوتر')),
      body: Column(
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
                          decoration: InputDecoration(
                              hintText: '',
                              border: OutlineInputBorder()
                          ),
                          controller: _wlSsidcontroller,
                        ),
                      ),
                      SizedBox(width: 10), // مسافة بين الحقول
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                              hintText: 'رمز الرواتر',
                              border: OutlineInputBorder()
                          ),
                          controller: _wlWpaPskcontroller,

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
                          decoration: InputDecoration(
                              hintText: 'Uaername',
                              border: OutlineInputBorder()
                          ),
                          controller: _usernamecontroller,
                        ),
                      ),
                      SizedBox(width: 10), // مسافة بين الحقول
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Password',
                              border: OutlineInputBorder()
                          ),
                          controller: _wlWpaPskcontroller,

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
                      value: _selectedHuaweiOption,
                      hint: Text('اختر نوع الباقة'),
                      items: const [
                        DropdownMenuItem(value: '1', child: Text('VL 1')),
                        DropdownMenuItem(value: '2', child: Text('VL 2')),
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
    );
  }
}