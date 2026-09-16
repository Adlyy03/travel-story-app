import '../../shared/models/location_point.dart';

class ElevationCalculator {
  static const double _minAltitudeDiff = 3.0;

  ElevationMetrics calculate(List<LocationPoint> points) {
    final altitudes = points
        .where((p) => p.altitude != null)
        .map((p) => p.altitude!)
        .toList();

    if (altitudes.length < 2) {
      return ElevationMetrics(
        gain: null,
        loss: null,
        highest: null,
        lowest: null,
      );
    }

    final smoothed = _smooth(altitudes);
    
    double gain = 0.0;
    double loss = 0.0;

    for (int i = 1; i < smoothed.length; i++) {
      final diff = smoothed[i] - smoothed[i - 1];
      if (diff.abs() >= _minAltitudeDiff) {
        if (diff > 0) {
          gain += diff;
        } else {
          loss += diff.abs();
        }
      }
    }

    return ElevationMetrics(
      gain: gain,
      loss: loss,
      highest: smoothed.reduce((a, b) => a > b ? a : b),
      lowest: smoothed.reduce((a, b) => a < b ? a : b),
    );
  }

  List<double> _smooth(List<double> values) {
    if (values.length < 3) return values;
    
    final smoothed = <double>[];
    smoothed.add(values[0]);

    for (int i = 1; i < values.length - 1; i++) {
      smoothed.add((values[i - 1] + values[i] + values[i + 1]) / 3);
    }

    smoothed.add(values[values.length - 1]);
    return smoothed;
  }
}

class ElevationMetrics {
  final double? gain;
  final double? loss;
  final double? highest;
  final double? lowest;

  ElevationMetrics({
    required this.gain,
    required this.loss,
    required this.highest,
    required this.lowest,
  });
}
