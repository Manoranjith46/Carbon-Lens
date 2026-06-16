import 'package:flutter/material.dart';

/// Carbon status determines the dynamic primary colour of the app.
enum CarbonStatus {
  /// No baseline available — uses teal
  neutral,

  /// 0–79% of carbon limit — uses green
  safe,

  /// 80–100% of carbon limit — green + amber warning
  nearLimit,

  /// Above 100% of carbon limit — uses red
  overLimit,
}

/// Calculates the carbon status based on current footprint vs limit.
CarbonStatus getCarbonStatus(double currentFootprint, double? carbonLimit) {
  if (carbonLimit == null || carbonLimit <= 0) {
    return CarbonStatus.neutral;
  }
  final percentage = (currentFootprint / carbonLimit) * 100;
  if (percentage > 100) {
    return CarbonStatus.overLimit;
  }
  if (percentage >= 80) {
    return CarbonStatus.nearLimit;
  }
  return CarbonStatus.safe;
}

/// Returns a human-readable label for the carbon status.
String carbonStatusLabel(CarbonStatus status) {
  switch (status) {
    case CarbonStatus.neutral:
      return 'Calculating';
    case CarbonStatus.safe:
      return 'Within limit';
    case CarbonStatus.nearLimit:
      return 'Approaching limit';
    case CarbonStatus.overLimit:
      return 'Limit exceeded';
  }
}

/// Returns an icon for the carbon status.
IconData carbonStatusIcon(CarbonStatus status) {
  switch (status) {
    case CarbonStatus.neutral:
      return Icons.explore_outlined;
    case CarbonStatus.safe:
      return Icons.check_circle_outline;
    case CarbonStatus.nearLimit:
      return Icons.warning_amber_rounded;
    case CarbonStatus.overLimit:
      return Icons.error_outline;
  }
}
