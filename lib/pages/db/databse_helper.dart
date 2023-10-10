import 'dart:io';

import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 2;

  static final table = 'users';
  static final columnId = 'id';
  static final columnUser = 'user';
  static final columnGender = 'gender'; // New field for gender
  static final columnDateOfBirth =
      'date_of_birth'; // New field for date of birth
  static final columnHeight = 'height'; // New field for height
  static final columnEducation = 'education'; // New field for education
  static final columnModelData = 'model_data';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static late Database _database;
  Future<Database> get database async {
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnUser TEXT NOT NULL,
            $columnGender TEXT NOT NULL, 
            $columnDateOfBirth TEXT NOT NULL,
            $columnHeight REAL NOT NULL,
            $columnEducation TEXT NOT NULL,
            $columnModelData TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(User user) async {
    Database db = await instance.database;
    return await db.insert(table, user.toMap());
  }

  Future<List<User>> queryAllUsers() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> users = await db.query(table);
    return users.map((u) => User.fromMap(u)).toList();
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }

  Future<User?> getUserByUsername(String username) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> users = await db.query(
      table,
      where: '$columnUser = ?',
      whereArgs: [username],
    );
    if (users.isNotEmpty) {
      return User.fromMap(users.first);
    } else {
      return null;
    }
  }
}
