import 'dart:math';

import 'package:flutter/material.dart';
import 'package:toolfoam/models/tools/tf_tool_data.dart';
import 'package:toolfoam/widgets/editor/tf_editor_config.dart';
import 'package:toolfoam/widgets/editor/tf_editor_logic.dart';

class TFEditorData extends ChangeNotifier {

  TFEditorData({
    this.data,
  });

  double _scale = 1.0;

  double get scale => _scale;
  set scale(double value) {
    if (value == _scale) return;
    _scale = value;
    notifyListeners();
  }

  double get scaleInverse => 1 / scale;

  double get effectiveGridSize => TFEditorConfig.minorGridSize * scale;
  int get gridRatio => (log(TFEditorConfig.effectiveMinorGridSizeMinimum / effectiveGridSize) / log(TFEditorConfig.majorGridDensity)).ceil();
  double get gridSize => TFEditorConfig.minorGridSize * pow(TFEditorConfig.majorGridDensity, gridRatio);

  Offset? _activePointer;
  Offset? get activePointer => _activePointer;
  set activePointer(Offset? value) {
    if (value == _activePointer) return;
    _activePointer = value;
    notifyListeners();
  }

  Offset? get nearestGridSnap {
    if (activePointer == null) return null;
    return Offset(
      (activePointer!.dx / gridSize).round() * gridSize,
      (activePointer!.dy / gridSize).round() * gridSize,
    );
  }

  bool? get shouldSnapToGrid  {
    if (activePointer == null) return null;
    return TFEditorLogic.interceptsSquare(nearestGridSnap!, activePointer!, TFEditorConfig.defaultSnapTolerance * scaleInverse);
  }


  Offset? get effectivePointerCoordinates {
    if (activePointer == null) return null;

    if (shouldSnapToGrid!) {
      return nearestGridSnap;
    }

    return activePointer;
  }

  TFToolData? data;
  TFToolData? get toolData => data;
  set toolData(TFToolData? value) {
    if (value == data) return;
    data = value;
    notifyListeners();
  }

}