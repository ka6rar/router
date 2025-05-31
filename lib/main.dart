import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:router/abstractt.dart';
import 'package:router/core/utils/deep_link_handler.dart';
import 'package:router/core/utils/messages.dart';
import 'package:router/core/utils/speed_step_router.dart';
import 'package:router/data/datasources/local/db_helper.dart';
import 'package:router/model_router.dart';
import 'package:router/core/constants/style.dart';
import 'package:router/presentation/screens/home/home_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DBHerper.database;
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: HomePage(),
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

  late WebViewControllerPlus _controller;
  bool _showWebView = false;
  String _statusMessage = '';
  bool _isLoading = false;
  RouterStrategy? _selectedRouter;
  bool nNTAuthentication = false;
  TextEditingController _usernamecontroller =  TextEditingController();
  TextEditingController _passoredcontroller =  TextEditingController();
  TextEditingController _wlSsidcontroller =  TextEditingController();
  TextEditingController _wlWpaPskcontroller =  TextEditingController();
  TextEditingController _onNTAuthenticationText =  TextEditingController();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final AppLinks _appLinks = AppLinks();
  String? selectedVlan;

  List<Map<String, String>> vlanlist = [
    {
      "name":  "1",
      "value": "1"
    },
    {
      "name":  "2",
      "value": "2"
    },
    {
      "name":  "لا يوجد",
      "value": "0"
    }
  ];


  Future<void> copyInfoUser() async {
    await deepLink(
      appLinks: _appLinks,
      wlSsidController: _wlSsidcontroller,
      wlWpaPskController: _wlWpaPskcontroller,
      usernameController: _usernamecontroller,
      passwordController: _passoredcontroller,
      vlanList: vlanlist,
      routerStrategies: _routerStrategies,
      onVlanChanged: (vlan) => setState(() => selectedVlan = vlan), // Callback
      onRouterChanged: (router) => setState(() => _selectedRouter = router), // Callback
    );
  }

  @override
  void initState() {
    super.initState();
    _updateIP();
    _connectivitySubscription =  _connectivity.onConnectivityChanged.listen((event) {
          _updateIP();
     },);
    // Also handle app start via a link
    copyInfoUser();
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
          ipAddress = "يدعم فقط واي فاي";
          setState(() {
            _statusMessage = ipAddress;
          });
       }
    if (connectivityResult.contains(ConnectivityResult.none)) {
       ipAddress =  "لا يوجد اتصال في شبكة";
       setState(() {
         _statusMessage = ipAddress;
       });

    }

  }
  final _formKey = GlobalKey<FormState>();

  final Map<String, RouterStrategy> _routerStrategies = {
    'HUAWEI_New': HuaweiRouterNew(),
    'HUAWEI_Old': HuaweiRouterOld(),
  };
  void messages(String statusMessage) {
    setState(() {
      _statusMessage = statusMessage;
      _controller.clearCache();
      _controller.clearLocalStorage();
    });
  }

  Future<void> runRouterAuth() async {
    if(_formKey.currentState!.validate()) {

      if (_selectedRouter == null   ) {
        setState(() => _statusMessage = 'الرجاء اختيار نوع الراوتر');
        return;
      }
      //ذا كانن الرواتر اهواي يفيتح انواع في لان
      if (selectedVlan == null && _selectedRouter is HuaweiRouterNew ||  selectedVlan == null &&  _selectedRouter is HuaweiRouterOld) {
        setState(() => _statusMessage = "  VL1 و VL2 اختار نواع");
        return;
      }
      setState(() {
        _isLoading = true;
        _statusMessage = 'جاري الاتصال بالراوتر...';
      });

      try {
        _controller = WebViewControllerPlus()
          ..addJavaScriptChannel(
            'FlutterPostMessage',
               onMessageReceived: (message) {
                 final String msg = message.message;
                 for (var entry in endingMessagesMap.entries) {
                   if (msg.endsWith(entry.key)) {
                     messages(entry.value);
                     return;
                   }
                 }

                 if( message.message == "portId") {
                   Future.delayed(const Duration(seconds: 1), () {
                     Navigator.of(context).pushAndRemoveUntil(
                       MaterialPageRoute(builder: (context) => const AutoRouterLogin()), // استبدل HomePage بالصفحة الرئيسية الحقيقية
                           (route) => false, // هذا يحذف كل الصفحات السابقة
                     );
                   });
                   _controller.clearLocalStorage();
                   _controller.clearCache();
                 }

            },
          )
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) async => await _handleRouterFlow(),
              onWebResourceError: (error) => setState(() {
                _statusMessage = 'خطأ في التحميل: ${error.description}';
                _isLoading = false;
              }),
            ),
          )
          ..loadRequest(Uri.parse("http://${ipAddress}"));

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

      if(_selectedRouter is HuaweiRouterNew)
      {

        await  speedStepRouter(_selectedRouter!, _usernamecontroller, _passoredcontroller, _wlSsidcontroller, _wlWpaPskcontroller,
      _controller, selectedVlan!,
     _onNTAuthenticationText, 3, 14, 33, 34, 2, 5, 15);
        // if (mounted) {
        //   Navigator.of(context).pushAndRemoveUntil(
        //     MaterialPageRoute(builder: (_) => AutoRouterLogin()),
        //         (route) => false,
        //   );
        // }

      } else  {
        await  speedStepRouter(_selectedRouter!, _usernamecontroller, _passoredcontroller, _wlSsidcontroller, _wlWpaPskcontroller,
            _controller, selectedVlan!,
            _onNTAuthenticationText, 3, 5, 15, 20, 2, 1 ,15
        );
       // if (mounted) {
       //   Navigator.of(context).pushAndRemoveUntil(
       //     MaterialPageRoute(builder: (_) => AutoRouterLogin()),
       //         (route) => false,
       //   );
       // }

      }


    } catch (e) {
      setState(() => _statusMessage = 'خطأ: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _usernamecontroller.dispose();
    _passoredcontroller.dispose();
    _wlSsidcontroller.dispose();
    _wlWpaPskcontroller.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
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
              if (!_statusMessage.startsWith("192.168."))
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
               statusMsg(),
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
                                hintStyle:   TextStyle(    fontFamily: fontF , color: Colors.green),
                                hintText: 'أسم الشبكة',
                                  border: OutlineInputBorder( borderSide: BorderSide(color: Colors.green) ),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,

                              ),
                              controller: _wlSsidcontroller,
                            ),
                          ),
                          const SizedBox(width: 10), // مسافة بين الحقول
                          Expanded(
                            child: TextFormField(
                              controller: _wlWpaPskcontroller,
                              decoration: const InputDecoration(
                                hintStyle:  TextStyle(    fontFamily: fontF , color: Colors.green),
                                hintText: 'رمز الراوتر',
                                  border: OutlineInputBorder( borderSide: BorderSide(color: Colors.green) ),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,

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
                                hintStyle:   TextStyle(    fontFamily: fontF , color: Colors.green),
                                hintText: 'Username', // ← تم تصحيح الكلمة من "Uaername" إلى "Username"
                               border: OutlineInputBorder( borderSide: BorderSide(color: Colors.green) ),
                               enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,
                               focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,
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
                              decoration:  const InputDecoration(
                                hintText: 'Password',
                                hintStyle:   TextStyle(    fontFamily: fontF , color: Colors.green),
                                border: OutlineInputBorder( borderSide: BorderSide(color: Colors.green) ),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,

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

                    ..._routerStrategies.entries.map((entry) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RadioListTile(
                        title: Text(entry.key , style: const TextStyle(fontFamily:fontF)),
                        value: entry.value,
                        groupValue: _selectedRouter,
                        activeColor:  Colors.green.shade100 ,
                        onChanged: (value) {
                          setState(() {
                            _selectedRouter = value;
                          });
                        },
                      ),
                    )),

                    if (_selectedRouter is HuaweiRouterNew ||  _selectedRouter is HuaweiRouterOld)...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green)
                              )
                          ),
                          value: selectedVlan,
                          hint: const Text('VLAN ID' , style: TextStyle(    fontFamily: fontF ,),),
                          items: vlanlist.map((code) {
                            return DropdownMenuItem(

                              value: code['value'],
                              child: Text(code['name']! , style: const TextStyle(    fontFamily: fontF ,),),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedVlan = value;

                            });
                          },
                        ),
                      ),
                      CheckboxListTile(
                        title: Text("ONT Authentication" , style: TextStyle(fontFamily: fontF),),
                        value: nNTAuthentication,
                        onChanged: (value) {
                          setState(() {
                            nNTAuthentication = value!;
                          });

                        },),
                      if(nNTAuthentication == true)
                      Padding(
                        padding: const EdgeInsets.only(right:16, left: 16, top: 5 ),
                        child: TextFormField(
                          textDirection: TextDirection.ltr,
                          controller: _onNTAuthenticationText, // ← تأكد من صحة الاسم
                          decoration:  const InputDecoration(
                            hintText: ' ONTرمز  التسلسلي',
                            hintStyle:   TextStyle(    fontFamily: fontF , color: Colors.green),
                            border: OutlineInputBorder( borderSide: BorderSide(color: Colors.green) ),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,
                          ),
                        ),
                      ),

                    ] ,


                    const SizedBox(height: 20,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.green.shade50),
                            overlayColor: WidgetStatePropertyAll(Colors.green.shade100.withOpacity(0.3)),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            fixedSize: const WidgetStatePropertyAll(Size(160, 50)),
                          ),
                          onPressed: _isLoading ? null : runRouterAuth,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.router_outlined, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'اتصال',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: fontF ,
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
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

  statusMsg() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: _statusMessage.contains('خطأ') ? Colors.red.shade800 : Colors.green.shade50,
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
                fontFamily: fontF ,
              ),
            ),
          ),
        ],
      ),
    );
  }
}