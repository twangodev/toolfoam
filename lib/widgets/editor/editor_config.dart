import 'dart:ui';

import '../../models/editing_tool.dart';

class EditorConfig {
  static const minScale = 1e-6;
  static const maxScale = 1e6;
  static const frictionCoefficient =
      0.0; // TODO 0.0 set for stability, any other positive value leads to funky issue with sliding/no feasible callback updating pointer (experiences on trackpad)

  static EditingTool defaultTool = EditingTool.select;

  static const unitsPerInch = 100.0;

  // User Experience

  static const defaultSnapTolerance = 16.0;

  static const confirmationMarkerSize = 10.0;
  static const confirmationMarkerDistance = 50.0;

  // Painter Configuration

  static const crossMarkerSize = 25.0;

  static const minorGridSize = 20.0;
  static const majorGridDensity = 5; // 100.0 is the majorGridSize

  static const effectiveMinorGridSizeMinimum = 15.0;

  static const ucsRadius = 12.0;
  static const ucsInnerRadius = 8.5;

  static const pointRadius = 5.0;

  static const checkmarkStrokeWidth = 2.0;
  static const Offset checkmarkStartBias = Offset(-1 / 2, -1 / 6);
  static const Offset checkmarkMiddleBias = Offset(-1 / 8, 2 / 7);
  static const Offset checkmarkEndBias = Offset(1 / 2, -1 / 3);

  static const double distanceMarkerStartOffset = 8.0;
  static const double distanceMarkerEndOffset = 70.0;
  static const double distanceMarkerArrowOffset = 67.5;
  static const double distanceMarkerArrowBase = 5.0;
  static const double distanceMarkerArrowHeight = 12.5;
}
