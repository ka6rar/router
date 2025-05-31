class UserModel {
  late final int? id;
  final String? name_r;
  final String? password_r;
  final String? userName;
  final String? password;
  final String? typeRouter;
  final String? vlan;
  final String? phoneNumber;

  UserModel(
    this.name_r,
    this.password_r,
    this.userName,
    this.password,
    this.typeRouter,
    this.vlan,
    this.phoneNumber,
  );

  UserModel.fromMap(Map<dynamic, dynamic> res)
      : id = res['id'],
        name_r = res['name_r'],
        password_r = res['password_r'],
        userName = res['userName'],
        password = res['password'],
        typeRouter = res['typeRouter'],
        vlan = res['vlan'],
        phoneNumber = res['phoneNumber'];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name_r': name_r,
      'password_r': password_r,
      'userName': userName,
      'password': password,
      'typeRouter': typeRouter,
      'vlan': vlan,
      'phoneNumber': phoneNumber,
    };
  }
}
