import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:router/core/constants/style.dart';
import 'package:router/data/datasources/local/db_helper.dart';
import 'package:router/data/models/user_model.dart';
import 'package:router/presentation/screens/users/adduser.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final DBHerper _dbHerper = DBHerper();
  final  TextEditingController searchController = TextEditingController();
  List  seacrch = [];
  List  users = [];

 Future<void> getUsers() async {
 List user = await _dbHerper.readData("SELECT * FROM user");
   setState(() {
     users = user;
   });
  }

  @override
  void initState() {
    getUsers();
    super.initState();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تفاصيل المستخدم" , style: TextStyle(fontFamily: fontF , fontSize: 16),) ,
      actions:[
        Center(
          child: IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Adduser(),));
          }, icon: const Icon(Icons.add)),
        ),
      ]
      
      ),
      body:  Column(
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: searchController,
                onChanged: (value) async {
                  setState(() {
                    seacrch = users.where((user) => user.nameUser!.contains(value)).toList();

                  });

                },
                decoration:  InputDecoration(
                  filled: true,
                  fillColor: Colors.green.shade50,
                  hintText: 'بحث عن مستخدم',
                  hintStyle: const TextStyle(fontFamily: fontF , color: Colors.green),
                  focusedBorder: OutlineInputBorder( // عند التركيز
                    borderRadius: BorderRadius.circular(8),
                    borderSide:  BorderSide(color: Colors.green.shade50),
                  ),
                  enabledBorder: OutlineInputBorder( // عند عدم التركيز
                    borderRadius: BorderRadius.circular(8),
                    borderSide:  BorderSide(color:Colors.green.shade50),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:  BorderSide(color: Colors.green.shade50),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:  BorderSide(color: Colors.green.shade50),
                  ),
                  errorStyle: const TextStyle(fontFamily: fontF),
                  labelStyle:  const TextStyle( fontFamily: fontF),
                ),
              ),
            ),
          ),
            users.isNotEmpty  && searchController.text.isEmpty ?  Expanded(
            child: users.isNotEmpty ? ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                UserModel  user =  users[index];
                return Padding(
                  padding: const EdgeInsets.all(13),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(16),

                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// الاسم ورقم الهاتف
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           crossAxisAlignment: CrossAxisAlignment.center,

                           children: [
                            const Icon(HeroIcons.phone, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(user.phoneNumber! , style: const TextStyle(fontFamily: fontF),),
                            const Spacer(),
                            Text(user.nameUser!, style: const TextStyle(fontFamily: fontF),),
                            const Icon(HeroIcons.user, color: Colors.green),
                          ],
                        ),
                        const SizedBox(height: 16),

                        /// كلمة المرور واسم المستخدم
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           crossAxisAlignment: CrossAxisAlignment.center,

                           children: [
                            const Icon(HeroIcons.lock_closed, color: Colors.green),
                            Text(user.password! , style: const TextStyle(fontFamily: fontF),),
                            const Spacer(),
                            Text(user.userName! , style: const TextStyle(fontFamily: fontF),),
                            const Icon(HeroIcons.server, color: Colors.green),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// رمز الراوتر واسم المستخدم
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           crossAxisAlignment: CrossAxisAlignment.center,

                           children: [
                            const Icon(HeroIcons.wifi, color: Colors.green),
                            Text(user.name_r!),
                            const Spacer(),
                            Text(user.password_r!),
                            const Icon(HeroIcons.key, color: Colors.green),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// رمز الراوتر واسم المستخدم
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           crossAxisAlignment: CrossAxisAlignment.center,

                           children: [
                            Text(user.typeRouter!),
                            const Spacer(),
                            const Text("نوع الراوتر" , style: TextStyle(fontFamily: fontF),),
                          ],
                        ),

                         if(user.ONT_Authaction != '')...[
                           const SizedBox(height: 16),
                           /// ID VLAN

                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                                Text(user.vlan! , style: const TextStyle(fontFamily: fontF),),
                               const Spacer(),
                               const Text("VLAN ID" , style: TextStyle(fontFamily: fontF),),
                             ],
                           ),
                           /// ID VLAN
                           const SizedBox(height: 16),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             crossAxisAlignment: CrossAxisAlignment.center,

                             children: [
                               Text(user.ONT_Authaction!),
                               const Spacer(),
                               const Text("رمز التسلسلي" , style: TextStyle(fontFamily: fontF),),
                             ],
                           ),
                           const SizedBox(height: 16),
                           /// Checkbox
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Checkbox(value: true, onChanged: (val) {

                               }),
                               const Text("ONT Attached" , style: TextStyle(fontFamily: fontF),),
                             ],
                           )
                         ] ,
                        const Divider(),
                        /// أزرار تعديل وحذف
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon:  Icon(Icons.edit, color: Colors.blue.shade600),
                              label: const Text("تعديل" , style: TextStyle(fontFamily: fontF, color: Colors.black),),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () async {
                                  _dbHerper.delete(user.id!);
                                  await getUsers();
                              },
                              icon:  Icon(Icons.delete, color: Colors.red.shade600),
                              label: const Text("حذف" , style: TextStyle(fontFamily: fontF , color: Colors.black),),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// زر واتساب
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                String url =  'https://miqat.online/page?name_r=${user.name_r}&password_r=${user.password_r}&username=${user.userName}&password=${user.password}&typeRouter=${user.typeRouter}&vlan=${user.vlan}';
                                if(user.ONT_Authaction == '') {
                                  final link = WhatsAppUnilink(
                                    phoneNumber: '+964${user.phoneNumber}',
                                    text: url,
                                  );
                                  await launchUrlString('$link');
                                } else {
                                  url = '$url&ont=true&ont_text=${user.ONT_Authaction}';
                                  final link = WhatsAppUnilink(
                                    phoneNumber: '+964${user.phoneNumber}',
                                    text: url,
                                  );
                                  await launchUrlString('$link');
                                }

                              },
                              icon: const Icon(Bootstrap.whatsapp, color: Colors.green),
                              label: const Text("إرسال عبر واتساب" , style: TextStyle(color: Colors.black , fontFamily: fontF),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Colors.black , width: 0.2)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ):  const Center(child:SizedBox()),
          ) :
          Expanded(
            child: seacrch.isNotEmpty  || searchController.text.isEmpty ?  ListView.builder(
              itemCount: seacrch.length,
              itemBuilder: (context, index) {
                UserModel  seacrched =  seacrch[index];
                return Padding(
                  padding: const EdgeInsets.all(13),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(16),

                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// الاسم ورقم الهاتف
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: [
                            const Icon(HeroIcons.phone, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(seacrched.phoneNumber! , style: const TextStyle(fontFamily: fontF),),
                            const Spacer(),
                            Text(seacrched.nameUser!, style: const TextStyle(fontFamily: fontF),),
                            const Icon(HeroIcons.user, color: Colors.green),
                          ],
                        ),
                        const SizedBox(height: 16),

                        /// كلمة المرور واسم المستخدم
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: [
                            const Icon(HeroIcons.lock_closed, color: Colors.green),
                            Text(seacrched.password! , style: const TextStyle(fontFamily: fontF),),
                            const Spacer(),
                            Text(seacrched.userName! , style: const TextStyle(fontFamily: fontF),),
                            const Icon(HeroIcons.server, color: Colors.green),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// رمز الراوتر واسم المستخدم
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: [
                            const Icon(HeroIcons.wifi, color: Colors.green),
                            Text(seacrched.name_r!),
                            const Spacer(),
                            Text(seacrched.password_r!),
                            const Icon(HeroIcons.key, color: Colors.green),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// رمز الراوتر واسم المستخدم
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,

                          children: [
                            Text(seacrched.typeRouter!),
                            const Spacer(),
                            const Text("نوع الراوتر" , style: TextStyle(fontFamily: fontF),),
                          ],
                        ),

                        if(seacrched.ONT_Authaction != '')...[
                          const SizedBox(height: 16),
                          /// ID VLAN

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(seacrched.vlan! , style: const TextStyle(fontFamily: fontF),),
                              const Spacer(),
                              const Text("VLAN ID" , style: TextStyle(fontFamily: fontF),),
                            ],
                          ),
                          /// ID VLAN
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [
                              Text(seacrched.ONT_Authaction!),
                              const Spacer(),
                              const Text("رمز التسلسلي" , style: TextStyle(fontFamily: fontF),),
                            ],
                          ),
                          const SizedBox(height: 16),
                          /// Checkbox
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Checkbox(value: true, onChanged: (val) {

                              }),
                              const Text("ONT Attached" , style: TextStyle(fontFamily: fontF),),
                            ],
                          )
                        ] ,
                        const Divider(),
                        /// أزرار تعديل وحذف
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon:  Icon(Icons.edit, color: Colors.blue.shade600),
                              label: const Text("تعديل" , style: TextStyle(fontFamily: fontF, color: Colors.black),),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () async {
                                await _dbHerper.delete(seacrched.id!);
                                await getUsers(); // تحديث القائمة الرئيسية
                                setState(() {
                                  seacrch.removeWhere((user) => user.id == seacrched.id); // تحديث قائمة البحث
                                });
                              },
                              icon:  Icon(Icons.delete, color: Colors.red.shade600),
                              label: const Text("حذف" , style: TextStyle(fontFamily: fontF , color: Colors.black),),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// زر واتساب
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                String url =  'https://miqat.online/page?name_r=${seacrched.name_r}&password_r=${seacrched.password_r}&username=${seacrched.userName}&password=${seacrched.password}&typeRouter=${seacrched.typeRouter}&vlan=${seacrched.vlan}';
                                if(seacrched.ONT_Authaction == '') {
                                  final link = WhatsAppUnilink(
                                    phoneNumber: '+964${seacrched.phoneNumber}',
                                    text: url,
                                  );
                                  await launchUrlString('$link');
                                } else {
                                  url = '$url&ont=true&ont_text=${seacrched.ONT_Authaction}';
                                  final link = WhatsAppUnilink(
                                    phoneNumber: '+964${seacrched.phoneNumber}',
                                    text: url,
                                  );
                                  await launchUrlString('$link');
                                }

                              },
                              icon: const Icon(Bootstrap.whatsapp, color: Colors.green),
                              label: const Text("إرسال عبر واتساب" , style: TextStyle(color: Colors.black , fontFamily: fontF),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Colors.black , width: 0.2)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ):  const Center(child:Text("لا توجد نتائج بحث مطابقة", style: TextStyle(fontFamily: fontF),)),
          ) ,
        ],
      ),
    );
  }
}
