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
    //tabla para guardar usuarios
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
    //tabla para gusrdar las tarejtas por usuario
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
    //tabla para ingresar los presupuestos
    await db.execute('''
  CREATE TABLE budgets(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    amount REAL,
    paymentDate TEXT,
    cardNumber TEXT,
    userId INTEGER,
    FOREIGN KEY (userId) REFERENCES users(id),
    FOREIGN KEY (cardNumber) REFERENCES cards(number)
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

  // metodo Para insertar presupuestos
  Future<int> insertBudget(Map<String, dynamic> budget) async {
    final db = await database;
    return await db.insert('budgets', budget);
  }

  // metodo Para obtener presupuestos por usuario
  Future<List<Map<String, dynamic>>> getBudgetsByUser(int userId) async {
    final db = await database;
    return await db.query('budgets', where: 'userId = ?', whereArgs: [userId]);
  }

  // metodo Para obtener presupuestos por tarjeta
  Future<List<Map<String, dynamic>>> getBudgetsByCard(String cardNumber) async {
    final db = await database;
    return await db.query(
      'budgets',
      where: 'cardNumber = ?',
      whereArgs: [cardNumber],
    );
  }

  // metodo Para actualizar presupuestos
  Future<int> updateBudget(Map<String, dynamic> budget) async {
    final db = await database;
    return await db.update(
      'budgets',
      budget,
      where: 'id = ?',
      whereArgs: [budget['id']],
    );
  }

  // metodo Para eliminar presupuestos
  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}
