import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/app_user_model.dart';
import '../models/exercise_session_model.dart';

class FirebaseService {
  FirebaseService();

  bool _isReady = false;
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  bool get isReady => _isReady;
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

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _isReady = true;
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() => _firebaseAuth.signOut();

  Future<void> saveUserProfile(AppUserModel user) async {
    await _firebaseDb.collection('users').doc(user.id).set({
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'city': user.city,
      'age': user.age,
      'isGuest': user.isGuest,
      'createdAt': user.createdAt.toIso8601String(),
      'lastSyncAt': user.lastSyncAt.toIso8601String(),
      'medicalNotes': user.medicalNotes,
      'preferences': user.preferences,
    }, SetOptions(merge: true));
  }

  Future<AppUserModel?> fetchUserProfile(String userId) async {
    final doc = await _firebaseDb.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    final data = doc.data()!;
    return AppUserModel(
      id: data['id'] as String,
      email: data['email'] as String,
      name: data['name'] as String,
      city: data['city'] as String? ?? 'غزة',
      age: (data['age'] as num?)?.toInt() ?? 0,
      isGuest: data['isGuest'] as bool? ?? false,
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ??
          DateTime.now(),
      lastSyncAt:
          DateTime.tryParse(data['lastSyncAt'] as String? ?? '') ?? DateTime.now(),
      medicalNotes: data['medicalNotes'] as String?,
      preferences:
          Map<String, dynamic>.from(data['preferences'] as Map? ?? const {}),
    );
  }

  Future<void> syncSession(ExerciseSessionModel session) async {
    await _firebaseDb
        .collection('users')
        .doc(session.userId)
        .collection('sessions')
        .doc(session.id)
        .set({
      'id': session.id,
      'exerciseId': session.exerciseId,
      'exerciseTitle': session.exerciseTitle,
      'startedAt': session.startedAt.toIso8601String(),
      'completedAt': session.completedAt.toIso8601String(),
      'durationSeconds': session.durationSeconds,
      'accuracyScore': session.accuracyScore,
      'repsCompleted': session.repsCompleted,
      'feedback': session.feedback,
      'offlineFeedback': session.offlineFeedback,
      'frameScores': session.frameScores,
      'metrics': session.metrics,
    }, SetOptions(merge: true));
  }
}
