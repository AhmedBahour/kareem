import 'dart:convert';

class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.level,
    required this.durationMinutes,
    required this.focusArea,
    required this.description,
    required this.instructions,
    required this.wellnessNote,
    required this.targetAccuracy,
    required this.jointTargets,
    this.requiresCamera = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String level;
  final int durationMinutes;
  final String focusArea;
  final String description;
  final List<String> instructions;
  final String wellnessNote;
  final double targetAccuracy;
  final List<JointTarget> jointTargets;
  final bool requiresCamera;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'level': level,
      'durationMinutes': durationMinutes,
      'focusArea': focusArea,
      'description': description,
      'instructions': jsonEncode(instructions),
      'wellnessNote': wellnessNote,
      'targetAccuracy': targetAccuracy,
      'jointTargets':
          jsonEncode(jointTargets.map((item) => item.toMap()).toList()),
      'requiresCamera': requiresCamera ? 1 : 0,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      category: map['category'] as String,
      level: map['level'] as String,
      durationMinutes: map['durationMinutes'] as int,
      focusArea: map['focusArea'] as String,
      description: map['description'] as String,
      instructions: List<String>.from(jsonDecode(map['instructions'] as String)),
      wellnessNote: map['wellnessNote'] as String,
      targetAccuracy: (map['targetAccuracy'] as num).toDouble(),
      jointTargets: (jsonDecode(map['jointTargets'] as String) as List)
          .map((item) => JointTarget.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      requiresCamera: (map['requiresCamera'] as int? ?? 1) == 1,
    );
  }
}

class JointTarget {
  const JointTarget({
    required this.name,
    required this.points,
    required this.minAngle,
    required this.maxAngle,
    required this.weight,
  });

  final String name;
  final List<String> points;
  final double minAngle;
  final double maxAngle;
  final double weight;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'points': points,
      'minAngle': minAngle,
      'maxAngle': maxAngle,
      'weight': weight,
    };
  }

  factory JointTarget.fromMap(Map<String, dynamic> map) {
    return JointTarget(
      name: map['name'] as String,
      points: List<String>.from(map['points'] as List),
      minAngle: (map['minAngle'] as num).toDouble(),
      maxAngle: (map['maxAngle'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
    );
  }
}
