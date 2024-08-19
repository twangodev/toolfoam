import 'dart:math';

import 'package:flutter/material.dart';
import 'package:toolfoam/geometry/point.dart';
import 'package:toolfoam/widgets/editor/editor_config.dart';

import '../../geometry/segment.dart';
import '../../models/snap.dart';
import '../../models/tf_id.dart';
import '../../models/tf_tool_data.dart';
import 'editor_logic.dart';

class EditorData extends ChangeNotifier {
  EditorData({
    required this.toolData,
    required this.gridToggleState,
  });

  bool Function() gridToggleState;

  void redraw() {
    notifyListeners();
  }

  double _scale = 1.0;

  double get scale => _scale;
  set scale(double value) {
    if (value == _scale) return;
    _scale = value;
    notifyListeners();
  }

  double get scaleInverse => 1 / scale;
  double get tolerance => EditorConfig.defaultSnapTolerance * scaleInverse;

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

  Snap? nearestGridSnap(Offset offset) {
    if (!gridToggleState()) return null;
    Offset target = Offset(
      (offset.dx / gridSize).round() * gridSize,
      (offset.dy / gridSize).round() * gridSize,
    );

    double tolerance = EditorConfig.defaultSnapTolerance;
    if (target == Offset.zero) tolerance = EditorConfig.ucsRadius * 2;
    tolerance *= scaleInverse;

    bool shouldSnap = EditorLogic.interceptsSquare(target, offset, tolerance);

    if (!shouldSnap) return null;
    double distanceSquared = (target - offset).distanceSquared;
    return Snap.grid(target, distanceSquared);
  }

  Snap? nearestPointSnap(Offset offset, Set<TfId> ignore) {
    Snap? snap;
    for (MapEntry<TfId, Point> entry in toolData.fixedPoints.entries) {
      TfId id = entry.key;
      Offset target = entry.value.toOffset();

      if (ignore.contains(id)) continue;

      bool isSnap = EditorLogic.interceptsCircle(target, offset, tolerance);

      if (!isSnap) continue;

      Offset delta = target - offset;
      double distanceSquared = delta.distanceSquared;
      Snap candidate = Snap.point(target, distanceSquared, id);

      if (snap == null || candidate < snap) snap = candidate;
    }

    return snap;
  }

  Snap? nearestSegmentSnap(Offset offset, Set<TfId> ignore) {
    Snap? snap;
    for (MapEntry<TfId, Segment> entry in toolData.segments.entries) {
      TfId id = entry.key;
      Segment segment = entry.value;

      if (ignore.contains(id)) continue;

      Point? start = toolData.fixedPoints[segment.a];
      Point? end = toolData.fixedPoints[segment.b];

      if (start == null || end == null) continue;

      Point targetPoint = EditorLogic.nearestPointOnSegment(start, end, offset);
      Offset target = targetPoint.toOffset();
      bool meetsTolerance =
          EditorLogic.interceptsCircle(target, offset, tolerance);

      if (!meetsTolerance) continue;

      Offset delta = target - offset;
      double distanceSquared = delta.distanceSquared;
      Snap candidate = Snap.line(target, distanceSquared, id);

      if (snap == null || candidate < snap) snap = candidate;
    }

    return snap;
  }

  Snap? nearestSnap(Offset pointer, Set<TfId> ignore) {
    Set<Snap> snaps = Set.identity();

    Snap? point = nearestPointSnap(pointer, ignore);
    if (point != null) snaps.add(point);

    Snap? segment = nearestSegmentSnap(pointer, ignore);
    if (segment != null) snaps.add(segment);

    Snap? grid = nearestGridSnap(pointer);
    if (grid != null) snaps.add(grid);

    if (snaps.isEmpty) return null;
    return snaps.reduce(Snap.min);
  }

  Snap? get snap {
    Offset? pointer = activePointer;
    if (pointer == null) return null;
    return nearestSnap(pointer, Set.identity());
  }

  TfToolData toolData;
  TfToolData preview = TfToolData();
  List<TfId> pointStack = [];

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

  TfId? _dragPointUuid;
  TfId? get dragPointUuid => _dragPointUuid;
  set dragPointUuid(TfId? value) {
    if (value == _dragPointUuid) return;
    _dragPointUuid = value;
    notifyListeners();
  }
}
