import 'package:flutter/material.dart';

import '../data/models/exercise_session_model.dart';
import '../data/repositories/app_repository.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider({required AppRepository repository})
      : _repository = repository;

  final AppRepository _repository;

  List<ExerciseSessionModel> _sessions = [];
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;

  List<ExerciseSessionModel> get sessions => _sessions;
  DateTime get selectedDate => _selectedDate;
  bool get loading => _loading;

  double get averageAccuracy {
    if (_sessions.isEmpty) {
      return 0;
    }
    final total = _sessions.fold<double>(
      0,
      (sum, session) => sum + session.accuracyScore,
    );
    return total / _sessions.length;
  }

  int get totalMinutes {
    final totalSeconds = _sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationSeconds,
    );
    return totalSeconds ~/ 60;
  }

  int get totalReps {
    return _sessions.fold<int>(
      0,
      (sum, session) => sum + session.repsCompleted,
    );
  }

  Future<void> loadForUser(String userId) async {
    _loading = true;
    notifyListeners();
    _sessions = await _repository.getSessions(userId);
    _loading = false;
    notifyListeners();
  }

  Future<void> filterByDate({
    required String userId,
    required DateTime date,
  }) async {
    _loading = true;
    _selectedDate = date;
    notifyListeners();
    _sessions = await _repository.getSessionsByDate(userId: userId, date: date);
    _loading = false;
    notifyListeners();
  }
}
