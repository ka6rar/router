import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:router/core/constants/style.dart';
import 'package:router/data/datasources/local/db_helper.dart';
import 'package:router/data/models/user_model.dart';
import 'package:router/presentation/screens/home/home_page.dart';


class EditUserScreen extends StatefulWidget {
  final UserModel user;

  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberusercontroller;
  late TextEditingController _nameusercontroller;
  late TextEditingController _wlSsidcontroller;
  late TextEditingController _wlWpaPskcontroller;
  late TextEditingController _usernamecontroller;
  late TextEditingController _passoredcontroller;
  late TextEditingController _onNTAuthenticationText;

  String stutsMsg = '';
  String selected_type_router = '';
  String? selectedVlan;
  bool onNTAuthentication_true_false = false;

  // Router strategies - يجب استبدالها بما يناسب حالتك
  final Map<String, dynamic> _routerStrategies = {
    'Huawei New': 'huawei_new',
    'Huawei Old': 'huawei_old',

  };

  dynamic _selectedRouter;

  // VLAN list - يجب استبدالها بما يناسب حالتك
  final _lanList = {
    'vlan': [
      {'value': '1', 'name': '1'},
      {'value': '2', 'name': '2'},
      {'value': '0', 'name': 'لا يوجد'},
    ]
  };

  @override
  void initState() {
    super.initState();

    // تهيئة المتحكمات بقيم المستخدم الحالي
    _numberusercontroller = TextEditingController(text: widget.user.phoneNumber);
    _nameusercontroller = TextEditingController(text: widget.user.nameUser);
    _wlSsidcontroller = TextEditingController(text: widget.user.name_r);
    _wlWpaPskcontroller = TextEditingController(text: widget.user.password_r);
    _usernamecontroller = TextEditingController(text: widget.user.userName);
    _passoredcontroller = TextEditingController(text: widget.user.password);
    _onNTAuthenticationText = TextEditingController(text: widget.user.ONT_Authaction);

    selected_type_router = widget.user.typeRouter ?? '';
    selectedVlan = widget.user.vlan;
    onNTAuthentication_true_false = widget.user.ONT_Authaction?.isNotEmpty ?? false;

    // تحديد نوع الراوتر المحدد مسبقاً
    _selectedRouter = _routerStrategies.entries .firstWhere((entry) => entry.key == selected_type_router,
        orElse: () => _routerStrategies.entries.first)
        .value;
  }

  @override
  void dispose() {
    _numberusercontroller.dispose();
    _nameusercontroller.dispose();
    _wlSsidcontroller.dispose();
    _wlWpaPskcontroller.dispose();
    _usernamecontroller.dispose();
    _passoredcontroller.dispose();
    _onNTAuthenticationText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل المستخدم", style: TextStyle(fontFamily: fontF, fontSize: 16)),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              if(stutsMsg != '')
                Text(stutsMsg),

              // رقم الهاتف واسم المشترك
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _numberusercontroller,
                        keyboardType: TextInputType.number,
                        maxLength: 11,
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(fontFamily: fontF, color: Colors.green),
                          hintText: 'رقم الهاتف',
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'رجاء ادخل اسم المشترك';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(fontFamily: fontF, color: Colors.green),
                          hintText: 'أسم المشترك',
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        ),
                        controller: _nameusercontroller,
                      ),
                    ),
                  ],
                ),
              ),

              // اسم الشبكة ورمز الراوتر
              SizedBox(
                height: 100,
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
                          hintStyle: TextStyle(fontFamily: fontF, color: Colors.green),
                          hintText: 'أسم الشبكة',
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        ),
                        controller: _wlSsidcontroller,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _wlWpaPskcontroller,
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(fontFamily: fontF, color: Colors.green),
                          hintText: 'رمز الراوتر',
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
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

              // رمز الاشتراك وكلمة مرور الاتصال
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _usernamecontroller,
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(fontFamily: fontF, color: Colors.green),
                          hintText: 'رمز الاشتراك',
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _passoredcontroller,
                        decoration: const InputDecoration(
                          hintText: 'كلمه مرور الاتصال',
                          hintStyle: TextStyle(fontFamily: fontF, color: Colors.green),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الرجاء إدخال كلمة المرور الاتصال';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // أنواع الراوتر
              ..._routerStrategies.entries.map((entry) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: RadioListTile(
                  title: Text(entry.key, style: const TextStyle(fontFamily: fontF)),
                  value: entry.value,
                  groupValue: _selectedRouter,
                  activeColor: Colors.green.shade100,
                  onChanged: (value) {
                    setState(() {
                      _selectedRouter = value;
                      selected_type_router = entry.key;
                    });
                  },
                ),
              )),

              // VLAN ID (لأنواع معينة من الراوتر)
              if (_selectedRouter == 'huawei_new' || _selectedRouter == 'huawei_old')...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green))
                    ),
                    value: selectedVlan,
                    hint: const Text('VLAN ID', style: TextStyle(fontFamily: fontF)),
                    items: _lanList['vlan']!.map<DropdownMenuItem<String>>((code) {
                      return DropdownMenuItem(
                        value: code['value'],
                        child: Text(code['name']!, style: const TextStyle(fontFamily: fontF)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedVlan = value;
                      });
                    },
                  ),
                ),

                // ONT Authentication
                CheckboxListTile(
                  checkColor: Colors.green,
                  activeColor: Colors.green.shade100,
                  title: const Text("ONT Authentication", style: TextStyle(fontFamily: fontF)),
                  value: onNTAuthentication_true_false,
                  onChanged: (value) {
                    setState(() {
                      onNTAuthentication_true_false = value!;
                    });
                  },
                ),

                if(onNTAuthentication_true_false)
                  Padding(
                    padding: const EdgeInsets.only(right: 16, left: 16, top: 5),
                    child: TextFormField(
                      textDirection: TextDirection.ltr,
                      controller: _onNTAuthenticationText,
                      decoration: const InputDecoration(
                        hintText: 'ONT رمز التسلسلي',
                        hintStyle: TextStyle(fontFamily: fontF, color: Colors.green),
                        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 40),

              // أزرار الحفظ والإلغاء
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: ButtonStyle(
                        fixedSize: const MaterialStatePropertyAll(Size(120, 50)),
                        shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.green.shade100)
                            )
                        )
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("إلغاء", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: fontF)),
                  ),

                  const SizedBox(width: 20),

                  TextButton(
                    style: ButtonStyle(
                        fixedSize: const MaterialStatePropertyAll(Size(120, 50)),
                        shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.green.shade100)
                            )
                        )
                    ),
                    onPressed: () async {
                      if(selected_type_router.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("اختار انواع الراوتر", style: TextStyle(fontFamily: fontF)),
                            backgroundColor: Colors.black,
                            duration: Duration(seconds: 4),
                          ),
                        );
                        return;
                      }

                      if((_selectedRouter == 'huawei_new' || _selectedRouter == 'huawei_old') && selectedVlan == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("اختار في لان", style: TextStyle(fontFamily: fontF)),
                            backgroundColor: Colors.black,
                            duration: Duration(seconds: 4),
                          ),
                        );
                        return;
                      }

                      if(_formKey.currentState!.validate()) {
                        final updatedUser = UserModel(
                          _wlSsidcontroller.text,
                          _wlWpaPskcontroller.text,
                          _usernamecontroller.text,
                          _passoredcontroller.text,
                          selected_type_router,
                          selectedVlan,
                          _numberusercontroller.text,
                          _nameusercontroller.text,
                          onNTAuthentication_true_false ? _onNTAuthenticationText.text : '',
                          widget.user.id
                        );

                        final dbHelper = DBHerper();
                        await dbHelper.updtaeQuantity(updatedUser);
                        SnackBar(
                          duration: const Duration(seconds: 3), // المدة قصيرة لجعلها ناعمة
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.black.withOpacity(0.85),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.greenAccent),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "تم التحديث المستخدم بنجاح",
                                  style: TextStyle(
                                    fontFamily: fontF,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        Navigator.pushAndRemoveUntil(context,  MaterialPageRoute(builder: (_) =>  HomePage(initialIndex: 1),),(route) => false, );
                      }
                    },
                    child: const Text("حفظ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontFamily: fontF)),
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