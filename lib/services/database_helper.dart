import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Bump para v4 para recriar tabela com nova coluna
    _database = await _initDB('habitracker_v4.db'); 
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print('📂 BANCO DE DADOS: $path');

    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Adicionada coluna github_avatar_url
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        github_username TEXT,
        github_avatar_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        emoji TEXT NOT NULL,
        userId TEXT NOT NULL,
        completedDays TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- MÉTODOS DE USUÁRIO ---

  Future<bool> registerUser(User user) async {
    final db = await instance.database;
    try {
      await db.insert('users', user.toMap());
      return true;
    } catch (e) {
      print("Erro ao registrar: $e");
      return false; 
    }
  }

  Future<User?> loginUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final db = await instance.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // --- MÉTODOS DE HÁBITOS ---

  Future<void> createHabit(Habit habit) async {
    final db = await instance.database;
    await db.insert(
      'habits', 
      habit.toMap(), 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<List<Habit>> readHabits(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'habits',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return result.map((json) => Habit.fromMap(json)).toList();
  }

  Future<void> updateHabit(Habit habit) async {
    final db = await instance.database;
    await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> deleteHabit(String id) async {
    final db = await instance.database;
    await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}