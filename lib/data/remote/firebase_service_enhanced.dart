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
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
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
      rethrow;
    }
  }

  void _monitorConnectivity() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      final wasOnline = _isOnline;
      _isOnline = !result.contains(ConnectivityResult.none);

      if (!wasOnline && _isOnline) {
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
        // Continue with next
      }
    }
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _pendingSyncOperations.clear();
  }

  Future<void> saveUserData(AppUserModel user) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    Future<void> operation() async {
      // Use toMap() and handle types carefully for Firestore
      final data = user.toMap();
      // Firestore stores isGuest as bool usually, but our model uses 1/0 for SQLite
      data['isGuest'] = user.isGuest;
      // Preferences should be a Map in Firestore
      data['preferences'] = user.preferences;

      await _firebaseDb.collection('users').doc(uid).set(data, SetOptions(merge: true));
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
        id: data['id'] as String? ?? uid,
        email: data['email'] as String? ?? '',
        name: data['name'] as String? ?? '',
        city: data['city'] as String? ?? '',
        age: (data['age'] as num?)?.toInt() ?? 0,
        isGuest: data['isGuest'] == true,
        createdAt: (data['createdAt'] is String) ? DateTime.parse(data['createdAt'] as String) : DateTime.now(),
        lastSyncAt: (data['lastSyncAt'] is String) ? DateTime.parse(data['lastSyncAt'] as String) : DateTime.now(),
        medicalNotes: data['medicalNotes'] as String?,
        preferences: Map<String, dynamic>.from(data['preferences'] as Map? ?? {}),
      );
    } catch (e) {
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
          .doc(session.id)
          .set(session.toMap(), SetOptions(merge: true));
    }

    if (_isOnline) {
      await operation();
    } else {
      _pendingSyncOperations.add(operation);
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
          .map((doc) => ExerciseSessionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Stream<List<ExerciseSessionModel>> watchUserSessions(String uid) {
    return _firebaseDb
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ExerciseSessionModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> deleteUserAccount() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid != null) {
      await _firebaseDb.collection('users').doc(uid).delete();
    }
    await _firebaseAuth.currentUser?.delete();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
