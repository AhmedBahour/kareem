import 'package:flutter/material.dart';

import '../data/models/app_user_model.dart';
import '../data/repositories/app_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AppRepository repository}) : _repository = repository;

  final AppRepository _repository;

  AppUserModel? _currentUser;
  bool _loading = false;
  String? _error;

  AppUserModel? get currentUser => _currentUser;
  bool get loading => _loading;
  bool get isAuthenticated => _currentUser != null && !_currentUser!.isGuest;
  bool get isGuest => _currentUser?.isGuest ?? true;
  String? get error => _error;

  Future<void> initialize() async {
    _currentUser = await _repository.ensureGuestUser();
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String city,
    required int age,
    String? medicalNotes,
  }) async {
    return _run(() async {
      _currentUser = await _repository.registerUser(
        name: name,
        email: email,
        password: password,
        city: city,
        age: age,
        medicalNotes: medicalNotes,
      );
      return true;
    });
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return _run(() async {
      _currentUser = await _repository.loginUser(
        email: email,
        password: password,
      );
      return true;
    });
  }

  Future<void> useGuestMode() async {
    _currentUser = await _repository.ensureGuestUser();
    notifyListeners();
  }

  Future<void> logout() async {
    _loading = true;
    notifyListeners();
    await _repository.logout();
    _currentUser = await _repository.ensureGuestUser();
    _loading = false;
    notifyListeners();
  }

  Future<bool> _run(Future<bool> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await action();
      return result;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
