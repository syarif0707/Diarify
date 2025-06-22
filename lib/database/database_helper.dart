import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart'; // <--- ADD THIS LINE
import '../models/user.dart';
import '../models/diary_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'diarify.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create User table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');
    // Create Diary Entry table
    await db.execute('''
      CREATE TABLE diary_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        title TEXT,
        content TEXT,
        mood TEXT,
        entryDate TEXT,
        imagePath TEXT,
        imageCaption TEXT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implement upgrade logic if your database schema changes in the future
    // For now, we'll keep it simple.
    if (oldVersion < 1) {
      // Example: If you add new columns in a future version
      // await db.execute("ALTER TABLE diary_entries ADD COLUMN newColumn TEXT;");
    }
  }

  // --- User Operations ---

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // --- Diary Entry Operations ---

  Future<int> insertDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.insert(
      'diary_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DiaryEntry>> getDiaryEntries(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'entryDate DESC',
    );
    return List.generate(maps.length, (i) {
      return DiaryEntry.fromMap(maps[i]);
    });
  }

  Future<List<DiaryEntry>> getDiaryEntriesByDate(int userId, DateTime date) async {
    final db = await database;
    String formattedDate = DateFormat('yyyy-MM-dd').format(date); // Corrected this line
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      where: 'userId = ? AND entryDate LIKE ?',
      whereArgs: [userId, '$formattedDate%'], // Matches entries for the specific date
      orderBy: 'entryDate DESC',
    );
    return List.generate(maps.length, (i) {
      return DiaryEntry.fromMap(maps[i]);
    });
  }

  Future<int> updateDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.update(
      'diary_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteDiaryEntry(int id) async {
    final db = await database;
    return await db.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Reflection Page Queries ---

  Future<Map<String, int>> getMoodStatistics(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT mood, COUNT(*) as count
      FROM diary_entries
      WHERE userId = ? AND mood IS NOT NULL AND mood != ''
      GROUP BY mood
    ''', [userId]);

    Map<String, int> moodCounts = {};
    for (var row in result) {
      moodCounts[row['mood']] = row['count'] as int;
    }
    return moodCounts;
  }

  Future<Map<String, int>> getDailyEntryCounts(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUBSTR(entryDate, 1, 10) AS day, COUNT(*) AS count
      FROM diary_entries
      WHERE userId = ?
      GROUP BY day
      ORDER BY day DESC
      LIMIT 7 -- Get last 7 days for example
    ''', [userId]);

    Map<String, int> dailyCounts = {};
    for (var row in result) {
      dailyCounts[row['day']] = row['count'] as int;
    }
    return dailyCounts;
  }

  Future<Map<String, int>> getWeeklyEntryCounts(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT STRFTIME('%Y-%W', entryDate) AS week, COUNT(*) AS count
      FROM diary_entries
      WHERE userId = ?
      GROUP BY week
      ORDER BY week DESC
      LIMIT 4 -- Get last 4 weeks for example
    ''', [userId]);

    Map<String, int> weeklyCounts = {};
    for (var row in result) {
      weeklyCounts[row['week']] = row['count'] as int;
    }
    return weeklyCounts;
  }

  // These methods were misplaced outside the class.
  // They are now correctly moved inside the DatabaseHelper class.
  Future<User?> getUserById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}