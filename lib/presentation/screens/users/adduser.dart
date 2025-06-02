import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:router/core/utils/v_lan_list.dart';
import 'package:router/data/datasources/local/db_helper.dart';
import 'package:router/data/models/user_model.dart';
import 'package:router/model_router.dart';

import '../../../abstractt.dart';
import '../../../core/constants/style.dart';

class Adduser extends StatefulWidget {
  const Adduser({super.key});
  @override
  State<Adduser> createState() => _AdduserState();
}

class _AdduserState extends State<Adduser> {
  @override
  RouterStrategy? _selectedRouter;
  String  stutsMsg = '';
  bool onNTAuthentication_true_false = false;
  TextEditingController _nameusercontroller =  TextEditingController();
  TextEditingController _numberusercontroller =  TextEditingController();
  TextEditingController _usernamecontroller =  TextEditingController();
  TextEditingController _passoredcontroller =  TextEditingController();
  TextEditingController _wlSsidcontroller =  TextEditingController();
  TextEditingController _wlWpaPskcontroller =  TextEditingController();
  TextEditingController _onNTAuthenticationText =  TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String selected_type_router = '';
  final Map<String, RouterStrategy> _routerStrategies = {
    'HUAWEI_New': HuaweiRouterNew(),
    'HUAWEI_Old': HuaweiRouterOld(),
  };
 VLanList _lanList = VLanList();
 DBHerper _dbHerper = DBHerper();
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  String? selectedVlan;


  Widget build(BuildContext context) {
    return  Scaffold(
     body: Form(
       key: _formKey,
       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: ListView(
           children: [
             if(stutsMsg != '')
             Text(stutsMsg),
             SizedBox(
               height: 100,
               width: double.infinity, // أو استخدم عرض مناسب أكبر من 100
               child: Row(
                 children: [
                   Expanded(
                     child: TextFormField(
                       controller: _numberusercontroller,
                       keyboardType: TextInputType.number,
                       maxLength: 11,
                       decoration: const InputDecoration(
                         hintStyle:  TextStyle(    fontFamily: fontF , color: Colors.green),
                         hintText: 'رقم الهاتف',
                         border: OutlineInputBorder( borderSide: BorderSide(color: Colors.green) ),
                         enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,
                         focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,

                       ),
                       validator: (value) {
                         if (value == null || value.trim().isEmpty) {
                           return 'الرجاء إدخال رقم الهاتف';
                         }

                         return null;
                       },
                     ),
                   ),
                   const SizedBox(width: 10), // مسافة بين الحقول
                   Expanded(
                     child: TextFormField(
                       validator: (value) {
                         if (value == "" ) {
                           return 'رجاء ادخل اسم المشترك';
                         }
                         return null;
                       },
                       decoration: const InputDecoration(
                         hintStyle:   TextStyle(    fontFamily: fontF , color: Colors.green),
                         hintText: 'أسم المشترك',
                         border: OutlineInputBorder( borderSide: BorderSide(color: Colors.green) ),
                         enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,
                         focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,

                       ),
                       controller: _nameusercontroller,
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
                         hintText: 'رمز الاشتراك', // ← تم تصحيح الكلمة من "Uaername" إلى "Username"
                         border: OutlineInputBorder( borderSide: BorderSide(color: Colors.green) ),
                         enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,
                         focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,
                       ),
                       keyboardType: TextInputType.text,
                       textInputAction: TextInputAction.next,
                       validator: (value) {
                         if (value == null || value.trim().isEmpty) {
                           return 'الرجاء إدخال رمز الاشتراك';
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
                         hintText: 'كلمه مرور الاتصال',
                         hintStyle:   TextStyle(    fontFamily: fontF , color: Colors.green),
                         border: OutlineInputBorder( borderSide: BorderSide(color: Colors.green) ),
                         enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,
                         focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)) ,

                       ),
                       validator: (value) {
                         if (value == null || value.trim().isEmpty) {
                           return '  الرجاء إدخال كلمة المرور الاتصال';
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
                      selected_type_router = entry.key ;
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
                   items: _lanList.vlan.map((code) {
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

             const SizedBox(height: 40,),
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 TextButton(

                   style: ButtonStyle(
                     fixedSize: const MaterialStatePropertyAll(Size(120, 50)),
                     shape: WidgetStatePropertyAll(
                         RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12),
                         side: BorderSide(color: Colors.green.shade100)
                         ))
                   ),
                     onPressed:()  async {
                     print(selected_type_router);
                       if(selected_type_router == '') {
                         setState(() {
                           stutsMsg =   "اختارانواع الراوتر";
                         });
                       } else
                       if(selectedVlan == null) {
                         setState(() {
                           stutsMsg =   "اختار في لان";
                         });
                       } else {
                         setState(() {
                           stutsMsg = '';
                         });
                       }

                     // if(_formKey.currentState!.validate()) {
                       await  _dbHerper.insert(UserModel(
                           _wlSsidcontroller.text,
                           _wlWpaPskcontroller.text,
                           _usernamecontroller.text,
                           _passoredcontroller.text,
                            selected_type_router,
                            selectedVlan ,
                           _numberusercontroller.text,
                           _nameusercontroller.text ,
                           _onNTAuthenticationText.text ?? ''
                       ));

                     // }
                     } ,
                     child: const Text("حفظ" , style: TextStyle(color: Colors.green , fontWeight: FontWeight.bold , fontFamily: fontF),)
                 ),
               ],
             )
           ],
         ),
       ),
     ),
    );
  }
}
