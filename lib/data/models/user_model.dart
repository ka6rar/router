class UserModel {
  final int? id;
  final String? name_r;
  final String? password_r;
  final String? userName;
  final String? password;
  final String? typeRouter;
  final String? vlan;
  final String? phoneNumber;
  final String? nameUser;
  final String? ONT_Authaction;

  UserModel(
      this.name_r,
      this.password_r,
      this.userName,
      this.password,
      this.typeRouter,
      this.vlan,
      this.phoneNumber,
      this.nameUser, // لا تنسَ الفاصلة هنا
      this.ONT_Authaction, // لا تنسَ الفاصلة هنا
      [this.id] // أضفنا id كـ optional parameter
      );

  UserModel.fromMap(Map<dynamic, dynamic> res)
      : id = res['id'],
        name_r = res['name_r'],
        password_r = res['password_r'],
        userName = res['username'],
        password = res['password'],
        typeRouter = res['type_router'],
        vlan = res['vlan'],
        phoneNumber = res['number_user'],
        ONT_Authaction = res['ONT_Authaction'],
        nameUser = res['name_user'];

  Map<String, Object?> toMap() {
    return {
      'name_r': name_r,
      'password_r': password_r,
      'username': userName,
      'password': password,
      'type_router': typeRouter,
      'vlan': vlan,
      'number_user': phoneNumber,
      'ONT_Authaction': ONT_Authaction,
      'name_user': nameUser
    };
  }
}
