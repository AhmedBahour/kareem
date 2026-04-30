import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../models/exercise_model.dart';
import '../models/motion_frame_result.dart';

class PoseTrackingService {
  PoseTrackingService()
      : _poseDetector = PoseDetector(
          options: PoseDetectorOptions(
            model: PoseDetectionModel.base,
            mode: PoseDetectionMode.stream,
          ),
        );

  final PoseDetector _poseDetector;
  bool _processing = false;
  bool _movementHigh = false;

  Future<MotionFrameResult?> processFrame({
    required CameraImage image,
    required CameraDescription camera,
    required ExerciseModel exercise,
  }) async {
    if (_processing) {
      return null;
    }

    _processing = true;
    try {
      final inputImage = _inputImageFromCameraImage(image, camera);
      if (inputImage == null) {
        return const MotionFrameResult(
          score: 0,
          statusLabel: 'تعذر تحليل الصورة',
          highlights: ['تنسيق الصورة غير مدعوم على هذا الجهاز'],
          detectedRep: false,
          metrics: {},
        );
      }

      final poses = await _poseDetector.processImage(inputImage);
      if (poses.isEmpty) {
        return const MotionFrameResult(
          score: 0,
          statusLabel: 'اقترب أكثر من الكاميرا',
          highlights: ['تأكد أن الجزء العلوي من الجسم ظاهر بالكامل'],
          detectedRep: false,
          metrics: {},
        );
      }

      final pose = poses.first;
      final scoreData = _scorePose(
        pose: pose,
        targets: exercise.jointTargets,
        targetAccuracy: exercise.targetAccuracy,
      );

      final mainAngle = scoreData.metrics['mainAngle'] as double?;
      bool detectedRep = false;
      if (mainAngle != null) {
        final midPoint = (exercise.jointTargets.first.minAngle +
                exercise.jointTargets.first.maxAngle) /
            2;

        if (mainAngle > midPoint + 8) {
          _movementHigh = true;
        } else if (_movementHigh && mainAngle < midPoint - 8) {
          _movementHigh = false;
          detectedRep = true;
        }
      }

      return MotionFrameResult(
        score: scoreData.score,
        statusLabel: scoreData.status,
        highlights: scoreData.highlights,
        detectedRep: detectedRep,
        metrics: scoreData.metrics,
      );
    } finally {
      _processing = false;
    }
  }

  Future<void> dispose() async {
    await _poseDetector.close();
  }

  _ScoreData _scorePose({
    required Pose pose,
    required List<JointTarget> targets,
    required double targetAccuracy,
  }) {
    double weightedScore = 0;
    double totalWeight = 0;
    final issues = <String>[];
    final metrics = <String, dynamic>{};

    for (var index = 0; index < targets.length; index++) {
      final target = targets[index];
      final points = target.points.map(_landmarkFromName).toList();

      if (points.any((element) => element == null)) {
        continue;
      }

      final first = pose.landmarks[points[0]!];
      final middle = pose.landmarks[points[1]!];
      final last = pose.landmarks[points[2]!];

      if (first == null || middle == null || last == null) {
        issues.add('لم يتم التقاط ${target.name} بوضوح');
        continue;
      }

      final angle = _calculateAngle(first, middle, last);
      metrics[target.name] = angle;
      if (index == 0) {
        metrics['mainAngle'] = angle;
      }

      final score = _scoreAngle(
        angle: angle,
        minAngle: target.minAngle,
        maxAngle: target.maxAngle,
      );
      weightedScore += score * target.weight;
      totalWeight += target.weight;

      if (score < 65) {
        if (angle < target.minAngle) {
          issues.add('ارفع المدى الحركي قليلًا في ${target.name}');
        } else if (angle > target.maxAngle) {
          issues.add('خفف التمدد قليلًا في ${target.name}');
        }
      }
    }

    final finalScore = totalWeight == 0 ? 0 : weightedScore / totalWeight;
    metrics['targetAccuracy'] = targetAccuracy;

    final normalizedScore = ((finalScore * 0.8) + (targetAccuracy * 0.2))
        .clamp(0.0, 100.0)
        .toDouble();

    final status = normalizedScore >= 85
        ? 'ممتاز'
        : normalizedScore >= 70
            ? 'مستقر'
            : normalizedScore >= 55
                ? 'بحاجة لتعديل'
                : 'أعد ضبط الوضعية';

    if (issues.isEmpty) {
      issues.add('الحركة متوازنة، استمر بهذا الإيقاع');
    }

    return _ScoreData(
      score: normalizedScore,
      status: status,
      highlights: issues.take(3).toList(),
      metrics: metrics,
    );
  }

  double _scoreAngle({
    required double angle,
    required double minAngle,
    required double maxAngle,
  }) {
    if (angle >= minAngle && angle <= maxAngle) {
      return 100;
    }

    final deviation = angle < minAngle ? minAngle - angle : angle - maxAngle;
    return math.max(0, 100 - (deviation * 2.2));
  }

  double _calculateAngle(
    PoseLandmark first,
    PoseLandmark middle,
    PoseLandmark last,
  ) {
    final radians = math.atan2(last.y - middle.y, last.x - middle.x) -
        math.atan2(first.y - middle.y, first.x - middle.x);
    final angle = radians.abs() * 180 / math.pi;
    return angle > 180 ? 360 - angle : angle;
  }

  PoseLandmarkType? _landmarkFromName(String name) {
    switch (name) {
      case 'leftShoulder':
        return PoseLandmarkType.leftShoulder;
      case 'rightShoulder':
        return PoseLandmarkType.rightShoulder;
      case 'leftElbow':
        return PoseLandmarkType.leftElbow;
      case 'rightElbow':
        return PoseLandmarkType.rightElbow;
      case 'leftWrist':
        return PoseLandmarkType.leftWrist;
      case 'rightWrist':
        return PoseLandmarkType.rightWrist;
      case 'leftHip':
        return PoseLandmarkType.leftHip;
      case 'rightHip':
        return PoseLandmarkType.rightHip;
      default:
        return null;
    }
  }

  InputImage? _inputImageFromCameraImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    final rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    if (rotation == null) {
      return null;
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) {
      return null;
    }

    if (Platform.isAndroid) {
      final bytes = _concatenatePlanes(image.planes);
      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    }

    if (Platform.isIOS && image.planes.isNotEmpty) {
      return InputImage.fromBytes(
        bytes: image.planes.first.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    }

    return null;
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final writeBuffer = WriteBuffer();
    for (final plane in planes) {
      writeBuffer.putUint8List(plane.bytes);
    }
    return writeBuffer.done().buffer.asUint8List();
  }
}

class _ScoreData {
  const _ScoreData({
    required this.score,
    required this.status,
    required this.highlights,
    required this.metrics,
  });

  final double score;
  final String status;
  final List<String> highlights;
  final Map<String, dynamic> metrics;
}
