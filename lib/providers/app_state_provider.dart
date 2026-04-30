import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../data/repositories/app_repository.dart';

class AppStateProvider extends ChangeNotifier {
  AppStateProvider({required AppRepository repository})
      : _repository = repository;

  final AppRepository _repository;
  final Connectivity _connectivity = Connectivity();

  bool _initialized = false;
  bool _isOnline = false;
  bool _isFirebaseAvailable = false;
  String? _error;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool get initialized => _initialized;
  bool get isOnline => _isOnline;
  bool get isFirebaseAvailable => _isFirebaseAvailable;
  String? get error => _error;

  Future<void> initialize() async {
    try {
      await _repository.initialize();
      _isFirebaseAvailable = _repository.isFirebaseReady;
      await _refreshConnectivity();
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (results) async {
          final wasOffline = !_isOnline;
          _isOnline = !results.contains(ConnectivityResult.none);
          notifyListeners();

          if (wasOffline && _isOnline) {
            await _repository.syncPendingSessions();
          }
        },
      );
      _initialized = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> _refreshConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = !results.contains(ConnectivityResult.none);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
