import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:toolfoam/models/tools/tf_tool_data.dart';
import 'package:toolfoam/widgets/editor/editor_config.dart';

import '../../models/line.dart';
import 'editor_logic.dart';

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

  Offset? nearestLineSnap(Offset offset, {String? ignoreUuid}) {
    Offset? nearestLineSnap;
    double nearestDistance = double.infinity;
    for (Line line in toolData.lines) {
      if (line.point1 == ignoreUuid || line.point2 == ignoreUuid) continue;

      Offset start = toolData.points[line.point1]!;
      Offset end = toolData.points[line.point2]!;

      Offset nearestPoint = EditorLogic.nearestPointOnLine(start, end, offset);
      Offset delta = nearestPoint - offset;
      double distance = delta.distanceSquared;

      bool isNearest = distance < nearestDistance;
      double threshold = EditorConfig.defaultSnapTolerance / 2 * scaleInverse;
      bool isSnap = distance < threshold * threshold;

      if (isNearest && isSnap) {
        nearestLineSnap = nearestPoint;
        nearestDistance = distance;
      }
    }

    return nearestLineSnap;
  }

  MapEntry<String, Offset>? nearestPointSnap(
      Offset offset, String? ignoreUuid) {
    MapEntry<String, Offset>? nearestPointSnap;
    double nearestDistance = double.infinity;
    for (MapEntry<String, Offset> entry in toolData.points.entries) {
      if (entry.key == ignoreUuid) continue;

      Offset point = entry.value;
      Offset delta = point - offset;
      double distance = delta.distanceSquared;

      bool isNearest = distance < nearestDistance;
      bool isSnap = EditorLogic.interceptsCircle(entry.value, offset,
          EditorConfig.defaultSnapTolerance / 2 * scaleInverse);

      if (isNearest && isSnap) {
        nearestPointSnap = entry;
        nearestDistance = distance;
      }
    }

    return nearestPointSnap;
  }

  Offset effectivePointerCoordinates(Offset offset, {String? ignoreUuid}) {
    MapEntry<String, Offset>? pointSnap = nearestPointSnap(offset, ignoreUuid);
    if (pointSnap != null) return pointSnap.value;

    Offset? lineSnap = nearestLineSnap(offset);
    if (lineSnap != null) return lineSnap;

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

  String? _dragPointUuid;
  String? get dragPointUuid => _dragPointUuid;
  set dragPointUuid(String? value) {
    if (value == _dragPointUuid) return;
    _dragPointUuid = value;
    notifyListeners();
  }
}
