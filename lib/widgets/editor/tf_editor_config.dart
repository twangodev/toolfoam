import '../../models/editing_tool.dart';

class TFEditorConfig {

  static const minScale = 1e-6;
  static const maxScale = 1e6;
  static const frictionCoefficient = 1e-8;

  static EditingTool defaultTool = EditingTool.select;

  // User Experience

  static const defaultSnapTolerance = 12.5;

  // Painter Configuration

  static const crossMarkerSize = 25.0;

  static const minorGridSize = 20.0;
  static const majorGridDensity = 5; // 100.0 is the majorGridSize

  static const effectiveMinorGridSizeMinimum = 15.0;

  static const ucsRadius = 12.0;
  static const ucsInnerRadius = 8.5;

  static const pointRadius = 5.0;

}