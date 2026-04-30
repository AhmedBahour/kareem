import 'dart:convert';

class ExerciseSessionModel {
  const ExerciseSessionModel({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.exerciseTitle,
    required this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
    required this.accuracyScore,
    required this.repsCompleted,
    required this.feedback,
    required this.isSynced,
    required this.offlineFeedback,
    required this.frameScores,
    required this.metrics,
  });

  final String id;
  final String userId;
  final String exerciseId;
  final String exerciseTitle;
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationSeconds;
  final double accuracyScore;
  final int repsCompleted;
  final String feedback;
  final bool isSynced;
  final String offlineFeedback;
  final List<double> frameScores;
  final Map<String, dynamic> metrics;

  ExerciseSessionModel copyWith({
    bool? isSynced,
  }) {
    return ExerciseSessionModel(
      id: id,
      userId: userId,
      exerciseId: exerciseId,
      exerciseTitle: exerciseTitle,
      startedAt: startedAt,
      completedAt: completedAt,
      durationSeconds: durationSeconds,
      accuracyScore: accuracyScore,
      repsCompleted: repsCompleted,
      feedback: feedback,
      isSynced: isSynced ?? this.isSynced,
      offlineFeedback: offlineFeedback,
      frameScores: frameScores,
      metrics: metrics,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'exerciseId': exerciseId,
      'exerciseTitle': exerciseTitle,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'accuracyScore': accuracyScore,
      'repsCompleted': repsCompleted,
      'feedback': feedback,
      'isSynced': isSynced ? 1 : 0,
      'offlineFeedback': offlineFeedback,
      'frameScores': jsonEncode(frameScores),
      'metrics': jsonEncode(metrics),
    };
  }

  factory ExerciseSessionModel.fromMap(Map<String, dynamic> map) {
    return ExerciseSessionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      exerciseId: map['exerciseId'] as String,
      exerciseTitle: map['exerciseTitle'] as String,
      startedAt: DateTime.parse(map['startedAt'] as String),
      completedAt: DateTime.parse(map['completedAt'] as String),
      durationSeconds: map['durationSeconds'] as int,
      accuracyScore: (map['accuracyScore'] as num).toDouble(),
      repsCompleted: map['repsCompleted'] as int,
      feedback: map['feedback'] as String,
      isSynced: (map['isSynced'] as int? ?? 0) == 1,
      offlineFeedback: map['offlineFeedback'] as String,
      frameScores: (jsonDecode(map['frameScores'] as String) as List)
          .map((item) => (item as num).toDouble())
          .toList(),
      metrics: Map<String, dynamic>.from(
        jsonDecode(map['metrics'] as String) as Map,
      ),
    );
  }
}
