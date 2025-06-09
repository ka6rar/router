import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:router/core/utils/loggers.dart';
import 'package:router/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';


class DBHerper {
  static Database? _database;
  String ? sizeDb ;
  String ?  messageStatus
  ;
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'user.db');
    return await openDatabase(path, version: 1,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
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


  Future<UserModel> insert(UserModel UserModel) async {
    var dbClient = await database;
    await dbClient.insert('user', UserModel.toMap());
    return UserModel;
  }


  Future<List<UserModel>> getUserModelList() async {
    var dbClient = await database;
    final List<Map<String, Object?>> queryRseult = await dbClient.query(
        'UserModel');
    return queryRseult.map((e) => UserModel.fromMap(e)).toList();
  }


  Future<int> delete(int id) async {
    var dbClient = await database;
    return await dbClient.delete("user", where: 'id=?', whereArgs: [id])
        .whenComplete(() {});
  }


  Future<int> updtaeQuantity(UserModel UserModel) async {
    var dbClient = await database;
    return await dbClient.update(
        "user",
        UserModel.toMap(),
        where: 'id=?',
        whereArgs: [UserModel.id]);
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

  Future<List<UserModel>> searchData(String sql) async {
    Database? mydb = await database;
    List<Map<String, dynamic>> response = await mydb.rawQuery(sql);
    return response.map((map) => UserModel.fromMap(map)).toList();
  }


  Future<void> exportDatabase() async {
    final databasesPath = await getApplicationDocumentsDirectory();
    final dbFile = File(join(databasesPath.path, 'user.db'));

    // تأكد من وجود الملف
    if (!await dbFile.exists()) {
      messageStatus =  "❌ قاعدة البيانات غير موجودة";
      return;
    }


    if (await Permission.manageExternalStorage.isGranted) {
      messageStatus  = "✅ تم منح الإذن";
    } else {
      final result = await Permission.manageExternalStorage.request();
      if (result.isGranted) {
        messageStatus  ="✅ الإذن تم منحه بعد الطلب";

      } else {
        messageStatus  ="❌ تم رفض الإذن";
        openAppSettings(); // فتح إعدادات التطبيق للسماح يدويًا
      }
    }


    final directory = Directory('/storage/emulated/0/Download'); // لأندرويد فقط
    final exportFile = File('${directory.path}/user.db');
    await exportFile.writeAsBytes(await dbFile.readAsBytes());
    print("✅ تم تصدير القاعدة إلى: ${exportFile.path}");
  }

  Future<void> importDatabase() async {
    // اختيار ملف قاعدة البيانات من الجهاز
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final selectedFile = File(result.files.single.path!);
      // مسار قاعدة البيانات داخل التطبيق
      final dbPath = await getApplicationDocumentsDirectory();
      final targetPath = join(dbPath.path, 'user.db'); // اسم القاعدة الأصلية
      // نسخ القاعدة الجديدة فوق القاعدة القديمة
      await selectedFile.copy(targetPath);
      messageStatus  ="✅ تم استيراد قاعدة البيانات بنجاح إلى ";
    } else {

      messageStatus  ="❌ لم يتم اختيار أي ملف.";
    }
  }

  Future<void> printSmartDatabaseSize() async {
    final databasesPath = await getApplicationDocumentsDirectory();
    final path = join(databasesPath.path, 'user.db'); // غيّر اسم القاعدة هنا

    final file = File(path);

    if (await file.exists()) {
      final bytes = await file.length();
      final kb = bytes / 1024;
      final mb = kb / 1024;
      final gb = mb / 1024;

      String sizeText;
      if (gb >= 1) {
        sizeDb = '${gb.toStringAsFixed(0)} GB';
      } else if (mb >= 1) {
        sizeDb = '${mb.toStringAsFixed(0)} MB';
      } else {
        sizeDb = '${kb.toStringAsFixed(0)} KB';
      }
    print(sizeDb);
    } else {
      print('❌ قاعدة البيانات غير موجودة.');
    }
  }
}