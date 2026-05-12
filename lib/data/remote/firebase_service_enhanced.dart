import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../models/app_user_model.dart';
import '../models/exercise_session_model.dart';

class FirebaseServiceEnhanced {
  FirebaseServiceEnhanced();

  bool _isReady = false;
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;

  final List<Function()> _pendingSyncOperations = [];

  bool get isReady => _isReady;
  bool get isOnline => _isOnline;
  
  FirebaseAuth get _firebaseAuth {
    if (_auth == null) {
      throw StateError('FirebaseAuth requested before Firebase initialization');
    }
    return _auth!;
  }

  FirebaseFirestore get _firebaseDb {
    if (_firestore == null) {
      throw StateError('Firestore requested before Firebase initialization');
    }
    return _firestore!;
  }

  User? get currentFirebaseUser => _auth?.currentUser;

  Future<void> initialize() async {
    if (_isReady) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;

      // Enable offline persistence
      _firestore?.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Monitor connectivity
      _monitorConnectivity();

      _isReady = true;
    } catch (e) {
      print('Firebase initialization error: $e');
      rethrow;
    }
  }

  void _monitorConnectivity() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      final wasOnline = _isOnline;
      _isOnline = !result.contains(ConnectivityResult.none);

      if (wasOnline && !_isOnline) {
        print('📡 Went offline - storing pending operations');
      } else if (!wasOnline && _isOnline) {
        print('📡 Back online - syncing pending operations');
        _syncPendingOperations();
      }
    });
  }

  Future<void> _syncPendingOperations() async {
    while (_pendingSyncOperations.isNotEmpty) {
      try {
        final operation = _pendingSyncOperations.removeAt(0);
        await operation();
      } catch (e) {
        print('Sync error: $e');
      }
    }
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _pendingSyncOperations.clear();
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  Future<void> saveUserData(AppUserModel user) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    Future<void> operation() async {
      await _firebaseDb.collection('users').doc(uid).set({
        'name': user.name,
        'email': user.email,
        'city': user.city,
        'age': user.age,
        'medicalNotes': user.medicalNotes,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    if (_isOnline) {
      await operation();
    } else {
      _pendingSyncOperations.add(operation);
    }
  }

  Future<AppUserModel?> getUserData(String uid) async {
    try {
      final doc = await _firebaseDb.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return AppUserModel(
        id: doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        city: data['city'] ?? '',
        age: data['age'] ?? 0,
        medicalNotes: data['medicalNotes'],
      );
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> saveExerciseSession(ExerciseSessionModel session) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    Future<void> operation() async {
      await _firebaseDb
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .add({
        'exerciseId': session.exerciseId,
        'exerciseTitle': session.exerciseTitle,
        'durationSeconds': session.durationSeconds,
        'accuracy': session.accuracy,
        'repsCompleted': session.repsCompleted,
        'feedback': session.feedback,
        'completedAt': FieldValue.serverTimestamp(),
      });
    }

    if (_isOnline) {
      await operation();
    } else {
      _pendingSyncOperations.add(operation);
      print('✓ Session saved locally, will sync when online');
    }
  }

  Future<List<ExerciseSessionModel>> getUserSessions(String uid) async {
    try {
      final snapshot = await _firebaseDb
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .orderBy('completedAt', descending: true)
          .limit(100)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return ExerciseSessionModel(
              id: doc.id,
              exerciseId: data['exerciseId'] ?? '',
              exerciseTitle: data['exerciseTitle'] ?? '',
              durationSeconds: data['durationSeconds'] ?? 0,
              accuracy: (data['accuracy'] ?? 0.0).toDouble(),
              repsCompleted: data['repsCompleted'] ?? 0,
              feedback: data['feedback'],
            );
          })
          .toList();
    } catch (e) {
      print('Error fetching sessions: $e');
      return [];
    }
  }

  // Real-time updates
  Stream<List<ExerciseSessionModel>> watchUserSessions(String uid) {
    return _firebaseDb
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            return ExerciseSessionModel(
              id: doc.id,
              exerciseId: data['exerciseId'] ?? '',
              exerciseTitle: data['exerciseTitle'] ?? '',
              durationSeconds: data['durationSeconds'] ?? 0,
              accuracy: (data['accuracy'] ?? 0.0).toDouble(),
              repsCompleted: data['repsCompleted'] ?? 0,
              feedback: data['feedback'],
            );
          })
          .toList();
    });
  }

  Future<Map<String, dynamic>> getUserStatistics(String uid) async {
    try {
      final sessions = await getUserSessions(uid);

      if (sessions.isEmpty) {
        return {
          'totalSessions': 0,
          'totalMinutes': 0,
          'averageAccuracy': 0.0,
          'totalReps': 0,
        };
      }

      final totalMinutes = sessions
          .fold<int>(0, (sum, session) => sum + (session.durationSeconds ~/ 60));
      final averageAccuracy = sessions
              .fold<double>(0, (sum, session) => sum + session.accuracy) /
          sessions.length;
      final totalReps =
          sessions.fold<int>(0, (sum, session) => sum + session.repsCompleted);

      return {
        'totalSessions': sessions.length,
        'totalMinutes': totalMinutes,
        'averageAccuracy': averageAccuracy,
        'totalReps': totalReps,
      };
    } catch (e) {
      print('Error fetching statistics: $e');
      return {};
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null) {
        await _firebaseDb.collection('users').doc(uid).delete();
      }
      await _firebaseAuth.currentUser?.delete();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
