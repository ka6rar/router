import 'package:path_provider/path_provider.dart';
import 'package:router/core/utils/loggers.dart';
import 'package:router/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';


class DBHerper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'user.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate , onUpgrade: (db, oldVersion, newVersion) async {
      // if (oldVersion < 3) {
      //   await db.execute('ALTER TABLE medicines ADD COLUMN notificationId INTEGER');
      //   print('Update');
      // }
    },);
  }

  static Future<void> _onCreate(Database db, int version) async {
    info("Done Create DB SqlLite");
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_r TEXT,
        password_r TEXT,
        username TEXT,
        password TEXT,
        ONT_Authaction TEXT,
        vlan TEXT,
        type_router TEXT,
        number_user TEXT,
        name_user TEXT
      )
    ''');


  }


  Future<UserModel> insert(UserModel UserModel) async  {
    var dbClient = await database ;
    await dbClient.insert('user', UserModel.toMap());
    return UserModel;
  }


  Future<List<UserModel>> getUserModelList() async  {
    var dbClient = await database ;
    final List<Map<String , Object?>> queryRseult = await dbClient.query('UserModel');
    return  queryRseult.map((e) => UserModel.fromMap(e)).toList();
  }



  Future<int> delete(int id) async  {
    var dbClient = await database ;
    return  await dbClient.delete("user" , where: 'id=?' , whereArgs:  [id]).whenComplete((){
    });
  }



  Future<int> updtaeQuantity(UserModel UserModel) async  {
    var dbClient = await database ;
    return  await dbClient.update(
        "user" ,
        UserModel.toMap(),
        where: 'id=?' ,
        whereArgs:  [UserModel.id]);
  }

Future<List<UserModel>> readData(String sql) async {
    Database? mydb = await database;
    List<Map> response = await mydb.rawQuery(sql);
    return response.map((map) => UserModel.fromMap(map)).toList();
  }


  Future<int> insertData(String sql) async {
    Database? mydb = await database;
    int response = await mydb.rawInsert(sql);
    return response;
  }

  Future<bool> exists(String id) async {
    var dbClient = await database;
    if (dbClient == null) return false; // تأكد من أن قاعدة البيانات ليست null
    var res = await dbClient.rawQuery("SELECT * FROM user WHERE id = ?", [id]);
    return res.isNotEmpty;
  }






}