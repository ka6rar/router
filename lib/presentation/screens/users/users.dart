import 'package:flutter/material.dart';
import 'package:router/presentation/screens/users/adduser.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تفاصيل المستخدم" ) ,
      actions:[
        Center(
          child: IconButton(onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Adduser(),));
          }, icon: Icon(Icons.add)),
        ),
      ]
      
      ),
      body: Padding(
        padding: const EdgeInsets.all(13),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.green.shade100),
                borderRadius: BorderRadius.circular(16),

              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// الاسم ورقم الهاتف
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.phone, color: Colors.green),
                      SizedBox(width: 8),
                      Text("07821764349"),
                      Spacer(),
                      Text("كرار جبر كريم", style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.person, color: Colors.green),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// كلمة المرور واسم المستخدم
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.lock_outline, color: Colors.green),
                      Text("password"),
                      Spacer(),
                      Text("User name"),
                      Icon(Icons.person_outline, color: Colors.green),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// رمز الراوتر واسم المستخدم
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.wifi, color: Colors.green),
                      Text("رمز الراوتر"),
                      Spacer(),
                      Text("اسم المستخدم"),
                      Icon(Icons.router, color: Colors.green),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// رمز الراوتر واسم المستخدم
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.wifi, color: Colors.green),
                      Text("tp-link"),
                      Spacer(),
                      Text("نوع الراوتر"),
                      Icon(Icons.router, color: Colors.green),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Checkbox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Checkbox(value: true, onChanged: (val) {}),
                      const Text("ONT Attached"),
                    ],
                  ),

                  const Divider(),

                  /// أزرار تعديل وحذف
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        label: const Text("تعديل"),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text("حذف"),
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
          ],
        ),
      ),
    );
  }
}
