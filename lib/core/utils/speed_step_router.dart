
import 'package:flutter/cupertino.dart';
import 'package:router/abstractt.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

Future<void> speedStepRouter(
    RouterStrategy  _selectedRouter ,
    TextEditingController _usernamecontroller ,
    TextEditingController _passoredcontroller ,
    TextEditingController _wlSsidcontroller ,
    TextEditingController _wlWpaPskcontroller ,
    WebViewControllerPlus  _controller  ,
    String selectedVlan ,
    TextEditingController _ontAuthcationController ,
    int  secondssLogin ,
    int  secondssstartCenter ,
    int  secondssLan ,
    int  secondsswan ,
    int  secondchangeWifiSettings ,
    int  secondreboot ,
    int  secondont ,

    )
  async {
  await _selectedRouter.login(_controller);
  await Future.delayed( Duration(seconds:secondssLogin));
  await _selectedRouter.startCenter(_controller);
  await Future.delayed( Duration(seconds:secondssstartCenter));
  await _selectedRouter.lan(_controller);
  await Future.delayed( Duration(seconds:secondont ));
  await _selectedRouter.ontAuth(_controller , _ontAuthcationController.text);
  await Future.delayed( Duration(seconds:secondssLan ));
  await _selectedRouter.wan(_controller ,selectedVlan  , _usernamecontroller.text , _passoredcontroller.text);
  await Future.delayed( Duration(seconds:secondsswan));
  await _selectedRouter.changeWifiSettings(_controller ,_wlSsidcontroller.text , _wlWpaPskcontroller.text  );
  await Future.delayed( Duration(seconds:secondchangeWifiSettings));
  await _selectedRouter.reboot(_controller);
  await Future.delayed( Duration(seconds:secondreboot));
}