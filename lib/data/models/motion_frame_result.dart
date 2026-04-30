class MotionFrameResult {
  const MotionFrameResult({
    required this.score,
    required this.statusLabel,
    required this.highlights,
    required this.detectedRep,
    required this.metrics,
  });

  final double score;
  final String statusLabel;
  final List<String> highlights;
  final bool detectedRep;
  final Map<String, dynamic> metrics;
}
