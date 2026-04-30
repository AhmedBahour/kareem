import 'package:flutter/material.dart';

import '../data/models/exercise_model.dart';
import '../data/repositories/app_repository.dart';

class ExerciseCatalogProvider extends ChangeNotifier {
  ExerciseCatalogProvider({required AppRepository repository})
      : _repository = repository;

  final AppRepository _repository;

  List<ExerciseModel> _allExercises = [];
  String _selectedCategory = 'الكل';
  bool _loading = false;

  List<ExerciseModel> get allExercises => _allExercises;
  bool get loading => _loading;
  String get selectedCategory => _selectedCategory;

  List<String> get categories => [
        'الكل',
        ...{
          ..._allExercises.map((exercise) => exercise.category),
        },
      ];

  List<ExerciseModel> get visibleExercises {
    if (_selectedCategory == 'الكل') {
      return _allExercises;
    }
    return _allExercises
        .where((exercise) => exercise.category == _selectedCategory)
        .toList();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _allExercises = await _repository.getExercises();
    _loading = false;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
