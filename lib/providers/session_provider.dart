import 'dart:io';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../data/models/app_user_model.dart';
import '../data/models/exercise_model.dart';
import '../data/models/exercise_session_model.dart';
import '../data/models/motion_frame_result.dart';
import '../data/remote/pose_tracking_service.dart';
import '../data/repositories/app_repository.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({
    required AppRepository repository,
    required PoseTrackingService poseTrackingService,
  })  : _repository = repository,
        _poseTrackingService = poseTrackingService;

  final AppRepository _repository;
  final PoseTrackingService _poseTrackingService;

  CameraController? _cameraController;
  CameraDescription? _cameraDescription;
  ExerciseModel? _exercise;
  AppUserModel? _user;
  Timer? _timer;

  bool _initializing = false;
  bool _running = false;
  bool _paused = false;
  double _currentScore = 0;
  String _statusLabel = 'جاهز';
  int _elapsedSeconds = 0;
  int _reps = 0;
  String? _error;
  final List<double> _frameScores = [];
  final List<String> _highlights = [];
  DateTime? _startedAt;

  CameraController? get cameraController => _cameraController;
  bool get initializing => _initializing;
  bool get running => _running;
  bool get paused => _paused;
  double get currentScore => _currentScore;
  String get statusLabel => _statusLabel;
  int get elapsedSeconds => _elapsedSeconds;
  int get reps => _reps;
  String? get error => _error;
  List<String> get highlights => List.unmodifiable(_highlights);

  Future<void> start({
    required ExerciseModel exercise,
    required AppUserModel user,
  }) async {
    _initializing = true;
    _error = null;
    _exercise = exercise;
    _user = user;
    _elapsedSeconds = 0;
    _reps = 0;
    _frameScores.clear();
    _highlights
      ..clear()
      ..add('ثبت الجوال بحيث يظهر الكتفان والذراعان');
    notifyListeners();

    try {
      final cameras = await availableCameras();
      _cameraDescription = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        _cameraDescription!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup:
            Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.nv21,
      );

      await _cameraController!.initialize();
      await _cameraController!.startImageStream(_onImage);

      _startedAt = DateTime.now();
      _running = true;
      _paused = false;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!_paused) {
          _elapsedSeconds++;
          notifyListeners();
        }
      });
    } catch (e) {
      _error = 'تعذر تشغيل الكاميرا: $e';
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  Future<void> _onImage(CameraImage image) async {
    if (!_running || _paused || _cameraDescription == null || _exercise == null) {
      return;
    }

    final MotionFrameResult? result = await _poseTrackingService.processFrame(
      image: image,
      camera: _cameraDescription!,
      exercise: _exercise!,
    );

    if (result == null) {
      return;
    }

    _currentScore = result.score;
    _statusLabel = result.statusLabel;
    _highlights
      ..clear()
      ..addAll(result.highlights);
    _frameScores.add(result.score);
    if (result.detectedRep) {
      _reps++;
    }
    notifyListeners();
  }

  void togglePause() {
    if (!_running) {
      return;
    }
    _paused = !_paused;
    notifyListeners();
  }

  Future<ExerciseSessionModel?> finish() async {
    if (_exercise == null || _user == null || _startedAt == null) {
      return null;
    }

    final averageScore = _frameScores.isEmpty
        ? _currentScore
        : _frameScores.reduce((a, b) => a + b) / _frameScores.length;

    final feedback = _buildFeedback(averageScore);
    final offlineFeedback = _buildOfflineFeedback(averageScore);

    final session = ExerciseSessionModel(
      id: _repository.createSessionId(),
      userId: _user!.id,
      exerciseId: _exercise!.id,
      exerciseTitle: _exercise!.title,
      startedAt: _startedAt!,
      completedAt: DateTime.now(),
      durationSeconds: _elapsedSeconds,
      accuracyScore: averageScore,
      repsCompleted: _reps,
      feedback: feedback,
      isSynced: false,
      offlineFeedback: offlineFeedback,
      frameScores: List<double>.from(_frameScores),
      metrics: {
        'finalStatus': _statusLabel,
        'highlights': _highlights,
      },
    );

    await _repository.saveSession(session);
    await disposeSession();
    return session;
  }

  String _buildFeedback(double score) {
    if (score >= 85) {
      return 'أداؤك ممتاز جدًا، الحركة متزنة ومدى الرفع مناسب.';
    }
    if (score >= 70) {
      return 'أداء جيد، فقط حافظ على البطء وثبات الكتفين.';
    }
    if (score >= 55) {
      return 'الأداء مقبول، حاول تقريب الذراع من المسار المطلوب.';
    }
    return 'التطبيق رصد انحرافًا واضحًا، أعد المحاولة بهدوء ومسافة أوضح أمام الكاميرا.';
  }

  String _buildOfflineFeedback(double score) {
    if (score >= 80) {
      return 'تم حفظ الجلسة محليًا، وعند عودة الإنترنت سنرفعها للسحابة بدون فقدان النتائج.';
    }
    return 'تم حفظ الجلسة محليًا مع ملاحظات فورية حتى بدون إنترنت، ويمكنك مراجعتها من شاشة التقدم.';
  }

  Future<void> disposeSession() async {
    _timer?.cancel();
    _timer = null;
    _running = false;
    _paused = false;

    if (_cameraController?.value.isStreamingImages ?? false) {
      await _cameraController?.stopImageStream();
    }
    await _cameraController?.dispose();
    _cameraController = null;
    notifyListeners();
  }

  @override
  void dispose() {
    disposeSession();
    _poseTrackingService.dispose();
    super.dispose();
  }
}
