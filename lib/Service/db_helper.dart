import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  // Patrón singleton para usar una única instancia en toda la app
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  // Getter para obtener la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Inicializa la base de datos
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Crea las tablas de la base de datos
  FutureOr<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        apellido_paterno TEXT,
        apellido_materno TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');
    await db.execute('''
    CREATE TABLE cards(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      number TEXT,
      type TEXT,
      amount TEXT,
      expiryDate TEXT,
      color INTEGER, 
      userId INTEGER, 
      FOREIGN KEY (userId) REFERENCES users(id)
    )
  ''');
  }

  // Método para insertar un usuario
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  // Método para obtener un usuario (ejemplo, para login)
  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Insertar tarjeta
  Future<int> insertCard(Map<String, dynamic> card) async {
    try {
      final db = await database;
      return await db.insert('cards', card);
    } catch (e) {
      //print('Error en insertCard: $e');
      return 0; // Retorna 0 si hay error
    }
  }

  // Obtener todas las tarjetas de un usuario
  Future<List<Map<String, dynamic>>> getCards(int userId) async {
    final db = await database;
    return await db.query('cards', where: 'userId = ?', whereArgs: [userId]);
  }
}
