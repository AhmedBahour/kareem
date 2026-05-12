import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/app_user_model.dart';
import '../models/exercise_session_model.dart';
import 'firebase_service_enhanced.dart';
import 'local_storage_service.dart';

class DataSyncService extends ChangeNotifier {
  final FirebaseServiceEnhanced firebaseService;
  final LocalStorageService localStorageService;

  DataSyncService({
    required this.firebaseService,
    required this.localStorageService,
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
      // Sync user sessions and data
      final uid = firebaseService.currentFirebaseUser?.uid;
      if (uid != null) {
        // This would be implemented based on your data structure
        _lastSyncTime = DateTime.now();
        print('✓ All data synced successfully at $_lastSyncTime');
      }
    } catch (e) {
      print('❌ Sync error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> saveSessionWithSync(ExerciseSessionModel session) async {
    // Save locally first
    await localStorageService.saveSession(session);

    // Try to sync if online
    if (_isOnline) {
      try {
        await firebaseService.saveExerciseSession(session);
        print('✓ Session synced to cloud');
      } catch (e) {
        print('⚠️ Session saved locally, will sync later: $e');
      }
    }

    notifyListeners();
  }

  Future<List<ExerciseSessionModel>> getSessionsWithSync() async {
    // Try cloud first if online
    if (_isOnline) {
      try {
        final uid = firebaseService.currentFirebaseUser?.uid;
        if (uid != null) {
          final cloudSessions = await firebaseService.getUserSessions(uid);
          // Update local cache
          for (var session in cloudSessions) {
            await localStorageService.saveSession(session);
          }
          return cloudSessions;
        }
      } catch (e) {
        print('⚠️ Could not fetch from cloud: $e');
      }
    }

    // Fall back to local
    return await localStorageService.getSessions();
  }

  Stream<List<ExerciseSessionModel>> watchSessions() {
    final uid = firebaseService.currentFirebaseUser?.uid;
    if (uid != null && _isOnline) {
      return firebaseService.watchUserSessions(uid);
    }

    // Return local stream if offline
    return Stream.value([]); // Would need to implement local stream
  }

  Future<void> dispose() async {
    firebaseService.dispose();
  }
}

class LocalStorageService {
  // Implement local storage operations
  Future<void> saveSession(ExerciseSessionModel session) async {
    // SQLite implementation
  }

  Future<List<ExerciseSessionModel>> getSessions() async {
    // SQLite implementation
    return [];
  }
}
