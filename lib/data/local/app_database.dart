import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/seed_data.dart';
import '../models/app_user_model.dart';
import '../models/exercise_model.dart';
import '../models/exercise_session_model.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'nabd_alharaka.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await _createTables(database);
      },
    );

    await _seedExercisesIfNeeded(db);
    return db;
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.usersTable} (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT NOT NULL,
        city TEXT NOT NULL,
        age INTEGER NOT NULL,
        isGuest INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        lastSyncAt TEXT NOT NULL,
        medicalNotes TEXT,
        preferences TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.exercisesTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        category TEXT NOT NULL,
        level TEXT NOT NULL,
        durationMinutes INTEGER NOT NULL,
        focusArea TEXT NOT NULL,
        description TEXT NOT NULL,
        instructions TEXT NOT NULL,
        wellnessNote TEXT NOT NULL,
        targetAccuracy REAL NOT NULL,
        jointTargets TEXT NOT NULL,
        requiresCamera INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.sessionsTable} (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        exerciseTitle TEXT NOT NULL,
        startedAt TEXT NOT NULL,
        completedAt TEXT NOT NULL,
        durationSeconds INTEGER NOT NULL,
        accuracyScore REAL NOT NULL,
        repsCompleted INTEGER NOT NULL,
        feedback TEXT NOT NULL,
        isSynced INTEGER NOT NULL,
        offlineFeedback TEXT NOT NULL,
        frameScores TEXT NOT NULL,
        metrics TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedExercisesIfNeeded(Database db) async {
    final count = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM ${AppConstants.exercisesTable}',
          ),
        ) ??
        0;

    if (count > 0) {
      return;
    }

    final batch = db.batch();
    for (final exercise in SeedData.exercises()) {
      batch.insert(AppConstants.exercisesTable, exercise.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<ExerciseModel>> getExercises() async {
    final db = await database;
    final rows = await db.query(AppConstants.exercisesTable, orderBy: 'title ASC');
    return rows.map(ExerciseModel.fromMap).toList();
  }

  Future<void> upsertUser(AppUserModel user) async {
    final db = await database;
    await db.insert(
      AppConstants.usersTable,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AppUserModel?> getUser(String id) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.usersTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return AppUserModel.fromMap(rows.first);
  }

  Future<void> insertSession(ExerciseSessionModel session) async {
    final db = await database;
    await db.insert(
      AppConstants.sessionsTable,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExerciseSessionModel>> getSessionsForUser(String userId) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.sessionsTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'completedAt DESC',
    );
    return rows.map(ExerciseSessionModel.fromMap).toList();
  }

  Future<List<ExerciseSessionModel>> getSessionsForUserByDate({
    required String userId,
    required DateTime date,
  }) async {
    final db = await database;
    final start = DateTime(date.year, date.month, date.day).toIso8601String();
    final end =
        DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

    final rows = await db.query(
      AppConstants.sessionsTable,
      where: 'userId = ? AND completedAt >= ? AND completedAt <= ?',
      whereArgs: [userId, start, end],
      orderBy: 'completedAt DESC',
    );
    return rows.map(ExerciseSessionModel.fromMap).toList();
  }

  Future<List<ExerciseSessionModel>> getUnsyncedSessions() async {
    final db = await database;
    final rows = await db.query(
      AppConstants.sessionsTable,
      where: 'isSynced = 0',
      orderBy: 'completedAt ASC',
    );
    return rows.map(ExerciseSessionModel.fromMap).toList();
  }

  Future<void> markSessionSynced(String sessionId) async {
    final db = await database;
    await db.update(
      AppConstants.sessionsTable,
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }
}
