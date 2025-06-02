import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:router/core/constants/style.dart';
import 'package:router/data/datasources/local/db_helper.dart';
import 'package:router/data/models/user_model.dart';
import 'package:router/presentation/screens/users/adduser.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  @override

  DBHerper _dbHerper = DBHerper();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تفاصيل المستخدم" ) ,
      actions:[
        Center(
          child: IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Adduser(),));
          }, icon: const Icon(Icons.add)),
        ),
      ]
      
      ),
      body: FutureBuilder(
        future: _dbHerper.readData("SELECT * FROM user"),
        builder: (BuildContext context,AsyncSnapshot snapshot) => snapshot.hasData ? ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            UserModel  user =  snapshot.data[index];
            return Padding(
              padding: const EdgeInsets.all(13),
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.green.shade100),
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
                        Text(user.phoneNumber! , style: TextStyle(fontFamily: fontF),),
                        const Spacer(),
                        Text(user.nameUser!, style: TextStyle(fontFamily: fontF),),
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
                        Text(user.password! , style: TextStyle(fontFamily: fontF),),
                        const Spacer(),
                        Text(user.userName! , style: TextStyle(fontFamily: fontF),),
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
                            Text(user.vlan! , style: TextStyle(fontFamily: fontF),),
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
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          label: const Text("تعديل" , style: TextStyle(fontFamily: fontF),),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _dbHerper.delete(user.id!);

                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text("حذف" , style: TextStyle(fontFamily: fontF),),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// زر واتساب
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.access_time, color: Colors.white),
                        label: const Text("إرسال عبر واتساب"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ):  Center(child: CircularProgressIndicator(color: Colors.green.shade100,)),
      ),
    );
  }
}
