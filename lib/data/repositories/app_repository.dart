import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../local/app_database.dart';
import '../models/app_user_model.dart';
import '../models/exercise_model.dart';
import '../models/exercise_session_model.dart';
import '../remote/firebase_service.dart';

class AppRepository {
  AppRepository({
    required AppDatabase database,
    required FirebaseService firebaseService,
  })  : _database = database,
        _firebaseService = firebaseService;

  final AppDatabase _database;
  final FirebaseService _firebaseService;

  bool get isFirebaseReady => _firebaseService.isReady;

  Future<void> initialize() async {
    await _database.database;
    try {
      await _firebaseService.initialize();
    } catch (_) {
      // Offline-first: the app still works locally when Firebase is unavailable.
    }
  }

  Future<List<ExerciseModel>> getExercises() => _database.getExercises();

  Future<AppUserModel> ensureGuestUser() async {
    final existing = await _database.getUser(AppConstants.localGuestUserId);
    if (existing != null) {
      return existing;
    }

    final guest = AppUserModel(
      id: AppConstants.localGuestUserId,
      email: AppConstants.localGuestEmail,
      name: 'مستخدم محلي',
      city: 'غزة',
      age: 0,
      isGuest: true,
      createdAt: DateTime.now(),
      lastSyncAt: DateTime.now(),
      medicalNotes: 'استخدام محلي بدون مزامنة',
      preferences: const {'theme': 'light', 'notifications': false},
    );
    await _database.upsertUser(guest);
    return guest;
  }

  Future<AppUserModel> registerUser({
    required String name,
    required String email,
    required String password,
    required String city,
    required int age,
    String? medicalNotes,
  }) async {
    final credential = await _firebaseService.register(
      email: email,
      password: password,
    );

    final user = AppUserModel(
      id: credential.user!.uid,
      email: email,
      name: name,
      city: city,
      age: age,
      isGuest: false,
      createdAt: DateTime.now(),
      lastSyncAt: DateTime.now(),
      medicalNotes: medicalNotes,
      preferences: const {'theme': 'light', 'notifications': true},
    );

    await _database.upsertUser(user);
    await _firebaseService.saveUserProfile(user);
    return user;
  }

  Future<AppUserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _firebaseService.login(
      email: email,
      password: password,
    );
    final userId = credential.user!.uid;

    final remoteUser = await _firebaseService.fetchUserProfile(userId);
    if (remoteUser != null) {
      await _database.upsertUser(remoteUser);
      return remoteUser;
    }

    final local = await _database.getUser(userId);
    if (local != null) {
      return local;
    }

    final fallbackUser = AppUserModel(
      id: userId,
      email: email,
      name: email.split('@').first,
      city: 'غزة',
      age: 0,
      isGuest: false,
      createdAt: DateTime.now(),
      lastSyncAt: DateTime.now(),
      medicalNotes: null,
      preferences: const {'theme': 'light', 'notifications': true},
    );

    await _database.upsertUser(fallbackUser);
    await _firebaseService.saveUserProfile(fallbackUser);
    return fallbackUser;
  }

  Future<void> logout() async {
    if (_firebaseService.isReady && _firebaseService.currentFirebaseUser != null) {
      await _firebaseService.logout();
    }
  }

  Future<void> saveSession(ExerciseSessionModel session) {
    return _database.insertSession(session);
  }

  Future<List<ExerciseSessionModel>> getSessions(String userId) {
    return _database.getSessionsForUser(userId);
  }

  Future<List<ExerciseSessionModel>> getSessionsByDate({
    required String userId,
    required DateTime date,
  }) {
    return _database.getSessionsForUserByDate(userId: userId, date: date);
  }

  Future<void> syncPendingSessions() async {
    if (!_firebaseService.isReady) {
      return;
    }

    final sessions = await _database.getUnsyncedSessions();
    for (final session in sessions) {
      if (session.userId == AppConstants.localGuestUserId) {
        continue;
      }
      await _firebaseService.syncSession(session);
      await _database.markSessionSynced(session.id);
    }
  }

  String createSessionId() => const Uuid().v4();
}
