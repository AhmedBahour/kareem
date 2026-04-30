import 'package:flutter_test/flutter_test.dart';
import 'package:kareem_project/core/utils/seed_data.dart';

void main() {
  test('seed data contains therapeutic exercises', () {
    final exercises = SeedData.exercises();

    expect(exercises, isNotEmpty);
    expect(exercises.first.instructions, isNotEmpty);
    expect(
      exercises.any((exercise) => exercise.category.contains('الكتف')),
      isTrue,
    );
  });
}
