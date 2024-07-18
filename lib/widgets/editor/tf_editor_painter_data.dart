import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:toolfoam/models/tools/tf_path_data.dart';
import 'package:toolfoam/widgets/editor/tf_editor_config.dart';
import 'package:toolfoam/widgets/editor/tf_editor_logic.dart';

class TfEditorData extends ChangeNotifier {

  TfEditorData({
    required this.toolData,
  });

  double _scale = 1.0;

  double get scale => _scale;
  set scale(double value) {
    if (value == _scale) return;
    _scale = value;
    notifyListeners();
  }

  double get scaleInverse => 1 / scale;

  double get effectiveGridSize => TfEditorConfig.minorGridSize * scale;
  int get gridRatio => (log(TfEditorConfig.effectiveMinorGridSizeMinimum / effectiveGridSize) / log(TfEditorConfig.majorGridDensity)).ceil();
  double get gridSize => TfEditorConfig.minorGridSize * pow(TfEditorConfig.majorGridDensity, gridRatio);

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
    double snapTolerance = TfEditorConfig.defaultSnapTolerance;
    if (snapped == Offset.zero) snapTolerance = TfEditorConfig.ucsRadius * 2;
    return TfEditorLogic.interceptsSquare(gridSnap(offset), offset, snapTolerance * scaleInverse);
  }

  bool? get activeShouldSnapToGrid  {
    if (activePointer == null) return null;
    return shouldSnapToGrid(activePointer!);
  }

  Offset effectivePointerCoordinates(Offset offset) {
    if (shouldSnapToGrid(offset)) {
      return gridSnap(offset);
    }

    return offset;
  }

  Offset? get activeEffectivePointer {
    if (activePointer == null) return null;
    return effectivePointerCoordinates(activePointer!);
  }

  TfToolData toolData;
  Queue<String> actionPointQueue = Queue();

}