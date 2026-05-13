import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../local/app_database.dart';
import '../models/exercise_session_model.dart';
import 'firebase_service_enhanced.dart';

class DataSyncService extends ChangeNotifier {
  final FirebaseServiceEnhanced firebaseService;
  final AppDatabase database;

  DataSyncService({
    required this.firebaseService,
    required this.database,
  });

  bool _isSyncing = false;
  bool _isOnline = true;
  DateTime? _lastSyncTime;

  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> initialize() async {
    // Initial connectivity check
    _updateConnectivityStatus();
    
    // Monitor connectivity
    Connectivity().onConnectivityChanged.listen((result) {
      _updateConnectivityStatus();
    });

    // Try to sync on initialize
    if (_isOnline) {
      await syncAllData();
    }
  }

  void _updateConnectivityStatus() {
    _isOnline = firebaseService.isOnline;
    notifyListeners();
  }

  Future<void> syncAllData() async {
    if (!_isOnline || _isSyncing) {
      return;
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final uid = firebaseService.currentFirebaseUser?.uid;
      if (uid != null) {
        // Sync pending local sessions to cloud
        final pendingSessions = await database.getUnsyncedSessions();
        for (var session in pendingSessions) {
          if (session.userId == uid) {
            await firebaseService.saveExerciseSession(session);
            await database.markSessionSynced(session.id);
          }
        }

        // Optionally fetch from cloud to local
        final cloudSessions = await firebaseService.getUserSessions(uid);
        for (var session in cloudSessions) {
          await database.insertSession(session.copyWith(isSynced: true));
        }

        _lastSyncTime = DateTime.now();
      }
    } catch (e) {
      // Silently handle sync errors
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> saveSessionWithSync(ExerciseSessionModel session) async {
    // Save locally first
    await database.insertSession(session);

    // Try to sync if online and not a guest session
    if (_isOnline && session.userId != 'guest_local_user') {
      try {
        await firebaseService.saveExerciseSession(session);
        await database.markSessionSynced(session.id);
      } catch (e) {
        // Silently fail, will sync later
      }
    }

    notifyListeners();
  }

  Future<List<ExerciseSessionModel>> getSessionsWithSync(String userId) async {
    return await database.getSessionsForUser(userId);
  }

  @override
  void dispose() {
    firebaseService.dispose();
    super.dispose();
  }
}
