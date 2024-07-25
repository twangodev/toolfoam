import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:toolfoam/models/tools/tf_path_data.dart';
import 'package:toolfoam/widgets/editor/editor_config.dart';
import 'package:toolfoam/widgets/editor/editor_util.dart';

class EditorData extends ChangeNotifier {
  EditorData({
    required this.toolData,
  });

  static final Logger logger = Logger('EditorData');

  void redraw() {
    notifyListeners();
  }

  double _scale = 1.0;

  double get scale => _scale;
  set scale(double value) {
    if (value == _scale) return;
    logger.finest(
        'Scaling update: $value, inverse: ${1 / value}, old: $_scale, ratio: ${value / _scale}');
    _scale = value;
    notifyListeners();
  }

  double get scaleInverse => 1 / scale;

  double get effectiveGridSize => EditorConfig.minorGridSize * scale;
  int get gridRatio =>
      (log(EditorConfig.effectiveMinorGridSizeMinimum / effectiveGridSize) /
              log(EditorConfig.majorGridDensity))
          .ceil();
  double get gridSize =>
      EditorConfig.minorGridSize *
      pow(EditorConfig.majorGridDensity, gridRatio);

  Offset? _activePointer;
  Offset? get activePointer => _activePointer;
  set activePointer(Offset? value) {
    if (value == _activePointer) return;
    _activePointer = value;
    notifyListeners();
  }

  Offset gridSnap(Offset offset) {
    return Offset(
      (offset.dx / gridSize).round() * gridSize,
      (offset.dy / gridSize).round() * gridSize,
    );
  }

  Offset? get activePointerGridSnap {
    if (activePointer == null) return null;
    return gridSnap(activePointer!);
  }

  bool shouldSnapToGrid(Offset offset) {
    Offset snapped = gridSnap(offset);
    double snapTolerance = EditorConfig.defaultSnapTolerance;
    if (snapped == Offset.zero) snapTolerance = EditorConfig.ucsRadius * 2;
    return EditorLogic.interceptsSquare(
        snapped, offset, snapTolerance * scaleInverse);
  }

  bool? get activeShouldSnapToGrid {
    if (activePointer == null) return null;
    return shouldSnapToGrid(activePointer!);
  }

  MapEntry<String, Offset>? nearestPointSnap(Offset offset) {
    for (MapEntry<String, Offset> entry in toolData.points.entries) {
      if (EditorLogic.interceptsCircle(entry.value, offset,
          EditorConfig.defaultSnapTolerance / 2 * scaleInverse)) {
        return entry;
      }
    }

    return null;
  }

  Offset effectivePointerCoordinates(Offset offset) {
    MapEntry<String, Offset>? pointSnap = nearestPointSnap(offset);
    if (pointSnap != null) return pointSnap.value;
    if (shouldSnapToGrid(offset)) return gridSnap(offset);

    return offset;
  }

  Offset? get activeEffectivePointer {
    if (activePointer == null) return null;
    return effectivePointerCoordinates(activePointer!);
  }

  TfToolData toolData;
  List<String> actionPointerStack = [];

  double? confirmationRadius;
  Offset? confirmationMarker;

  bool shouldConfirm(Offset offset) {
    if (confirmationMarker == null || confirmationRadius == null) return false;
    return EditorLogic.interceptsCircle(
        confirmationMarker!, offset, confirmationRadius!);
  }

  bool? get isActiveOnConfirmation {
    if (activePointer == null) return null;
    return shouldConfirm(activePointer!);
  }
}
