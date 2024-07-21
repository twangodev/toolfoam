import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:toolfoam/extensions/list_extensions.dart';
import 'package:toolfoam/models/editing_tool.dart';
import 'package:toolfoam/widgets/editor/tf_editor_config.dart';
import 'package:toolfoam/widgets/editor/tf_editor_painter_data.dart';
import 'package:vector_math/vector_math_64.dart' show Quad;

import '../../models/line.dart';
import '../../models/tools/tf_path_data.dart';

class TfEditorPainter extends CustomPainter {

  final Quad viewport;
  final bool toggleGrid;
  final TfEditorData editorData;
  final EditingTool editingTool;
  final Queue<Function(Canvas)> highestLayer = Queue();

  static const Offset origin = Offset(0, 0);

  TfEditorPainter({
    required this.viewport,
    required this.editorData,
    required this.toggleGrid,
    required this.editingTool,
  });

  late final visibleRect = Rect.fromLTRB(viewport.point0.x, viewport.point0.y, viewport.point2.x, viewport.point2.y,);
  
  late final double scale = editorData.scale;
  late final double scaleInverse = editorData.scaleInverse;
  late final double effectiveGridSize = editorData.effectiveGridSize;
  late final int gridRatio = editorData.gridRatio;
  late final double gridSize = editorData.gridSize;
  late final Offset? activePointer = editorData.activePointer;
  late final Offset? activePointerGridSnap = editorData.activePointerGridSnap;
  late final Offset? activeEffectivePointer = editorData.activeEffectivePointer;
  late final bool? activeShouldSnapToGrid = editorData.activeShouldSnapToGrid;
  late final TfToolData toolData = editorData.toolData;
  late final actionPointQueue = editorData.actionPointerStack;

  bool confirmationMarkerDrawn = false;

  late final scaledVisibleRect = Rect.fromLTRB(
      (visibleRect.left / gridSize).floorToDouble(),
      (visibleRect.top / gridSize).ceilToDouble(),
      (visibleRect.right / gridSize).floorToDouble(),
      (visibleRect.bottom / gridSize).ceilToDouble(),
  );

  void registerDataOutput() {
    confirmationMarkerDrawn = false;
  }

  void defaultDataOutput() {
    if (!confirmationMarkerDrawn) {
      editorData.confirmationMarker = null;
      editorData.confirmationRadius = null;
    }
  }

  void drawCenterAxis(Canvas canvas) {
    final Paint xAxis = Paint()
      ..color = Colors.red
      ..strokeWidth = 2 * scaleInverse;

    final Paint yAxis = Paint()
      ..color = Colors.green
      ..strokeWidth = 2 * scaleInverse;

    canvas.drawLine(Offset(visibleRect.topLeft.dx, origin.dy), Offset(visibleRect.bottomRight.dx, origin.dy), xAxis);
    canvas.drawLine(Offset(origin.dx, visibleRect.topLeft.dy), Offset(origin.dx, visibleRect.bottomRight.dy), yAxis);
  }

  void drawUcsIcon(Canvas canvas) {
    final Paint grayUcsBackground = Paint()
      ..color = Colors.grey.shade700.withOpacity(0.5);

    final Paint grayUcsForeground = Paint()
      ..color = Colors.grey.shade500
      ..style = PaintingStyle.fill;

    Path topLeft = Path()
      ..moveTo(0, 0)
      ..lineTo(-TfEditorConfig.ucsInnerRadius * scaleInverse, 0)
      ..arcToPoint(
        Offset(0, -TfEditorConfig.ucsInnerRadius * scaleInverse),
        radius: Radius.circular(TfEditorConfig.ucsInnerRadius * scaleInverse),
        clockwise: true,
      )
      ..close();

    Path bottomRight = Path()
      ..moveTo(0, 0)
      ..lineTo(TfEditorConfig.ucsInnerRadius * scaleInverse, 0)
      ..arcToPoint(
        Offset(0, TfEditorConfig.ucsInnerRadius * scaleInverse),
        radius: Radius.circular(TfEditorConfig.ucsInnerRadius * scaleInverse),
        clockwise: true,
      )
      ..close();

    canvas.drawCircle(origin, TfEditorConfig.ucsRadius * scaleInverse, grayUcsBackground);
    canvas.drawPath(topLeft, grayUcsForeground);
    canvas.drawPath(bottomRight, grayUcsForeground);

  }

  void establishCenterMarkings(Canvas canvas) {
    drawCenterAxis(canvas);
    drawUcsIcon(canvas);
  }

  void establishGrid(Canvas canvas) {

    final Paint minorGrid = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 0.5 * scaleInverse;

    final Paint majorGrid = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 1 * scaleInverse;

    if (!toggleGrid) return;

    // Drawing horizontal lines
    for (int i = scaledVisibleRect.top.toInt(); i <= scaledVisibleRect.bottom.toInt(); i++) {
      double y = i * gridSize;
      if (y == 0) continue;
      Paint selectedPaint = (i % TfEditorConfig.majorGridDensity == 0) ? majorGrid : minorGrid;
      canvas.drawLine(Offset(visibleRect.left, y), Offset(visibleRect.right, y), selectedPaint);
    }

    // Drawing vertical lines
    for (int i = scaledVisibleRect.left.toInt(); i <= scaledVisibleRect.right.toInt(); i++) {
      double x = i * gridSize;
      if (x == 0) continue;
      Paint selectedPaint = (i % TfEditorConfig.majorGridDensity == 0) ? majorGrid : minorGrid;
      canvas.drawLine(Offset(x, visibleRect.top), Offset(x, visibleRect.bottom), selectedPaint);
    }

  }

  void drawCrossMarker(Canvas canvas, Offset offset) {
    final Paint crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2 * scaleInverse
      ..style = PaintingStyle.stroke;

    double halfSize = TfEditorConfig.crossMarkerSize * scaleInverse / 2;

    canvas.drawLine(offset.translate(-halfSize, 0), offset.translate(halfSize, 0), crossPaint);
    canvas.drawLine(offset.translate(0, -halfSize), offset.translate(0, halfSize), crossPaint);

  }

  void drawSnapMarker(Canvas canvas, Offset offset) {
    final Paint snapPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.5 * scaleInverse
      ..style = PaintingStyle.stroke;

    double defaultSize = TfEditorConfig.defaultSnapTolerance;
    if (offset == origin) defaultSize = TfEditorConfig.ucsRadius * 2;
    double scaledSize = defaultSize * scaleInverse;
    Rect rect = Rect.fromCenter(center: offset, width: scaledSize, height: scaledSize);

    canvas.drawRect(rect, snapPaint);
  }

  void establishGridSnap(Canvas canvas) {
    if (activeShouldSnapToGrid!) {
      drawSnapMarker(canvas, activePointerGridSnap!);
      drawCrossMarker(canvas, activePointerGridSnap!);
    } else {
      drawCrossMarker(canvas, activePointer!);
    }
  }

  void establishMarker(Canvas canvas) {
  if (!editingTool.allowsMarker || activePointer == null) return;
    if (toolData.points.values.contains(activeEffectivePointer!)) {
      drawSnapMarker(canvas, activePointerGridSnap!);
      return;
    }

    establishGridSnap(canvas);
  }

  void drawPoints(Canvas canvas) {
    final Paint fillPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2 * scaleInverse
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = Colors.grey.shade900
      ..strokeWidth = 2 * scaleInverse
      ..style = PaintingStyle.stroke;

    for (Offset point in toolData!.points.values) {
      canvas.drawCircle(point, TfEditorConfig.pointRadius * scaleInverse, fillPaint);
      canvas.drawCircle(point, TfEditorConfig.pointRadius * scaleInverse, strokePaint);
    }
  }

  void drawLines(Canvas canvas) {
    final Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2 * scaleInverse;

    for (Line line in toolData.lines) {
      Offset start = toolData.points[line.point1]!;
      Offset end = toolData.points[line.point2]!;
      canvas.drawLine(start, end, linePaint);
    }
  }

  void drawConfirmationMarker(Canvas canvas, Offset offset, Offset direction) {
    confirmationMarkerDrawn = true;

    Paint background = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 2 * scaleInverse
      ..style = PaintingStyle.fill;

    Paint foreground = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 2 * scaleInverse
      ..style = PaintingStyle.stroke;

    double confirmationRadius = TfEditorConfig.confirmationMarkerSize * scaleInverse;

    Offset perpendicular = Offset(-direction.dy, direction.dx);
    Offset center = offset + perpendicular * TfEditorConfig.confirmationMarkerDistance * scaleInverse;

    editorData.confirmationRadius = confirmationRadius;
    editorData.confirmationMarker = center;

    bool isHovered = editorData.isActiveOnConfirmation!;
    if (isHovered) background.color = Colors.green;

    final Paint checkmarkPaint = Paint()
      ..color = isHovered ? Colors.white : Colors.green
      ..strokeWidth = TfEditorConfig.checkmarkStrokeWidth * scaleInverse;

    Offset start = center + TfEditorConfig.checkmarkStartBias * confirmationRadius;
    Offset middle = center + TfEditorConfig.checkmarkMiddleBias * confirmationRadius;
    Offset end = center + TfEditorConfig.checkmarkEndBias * confirmationRadius;

    highestLayer.add((Canvas canvas) {
      canvas.drawCircle(center, confirmationRadius, background);
      canvas.drawCircle(center, confirmationRadius, foreground);

      canvas.drawLine(start, middle, checkmarkPaint);
      canvas.drawCircle(middle, checkmarkPaint.strokeWidth / 2, checkmarkPaint);
      canvas.drawLine(middle, end, checkmarkPaint);
    });

  }

  void drawEditToolPreview(Canvas canvas) {
    if (activePointer == null) return;

    if (editingTool == EditingTool.line) {
      if (actionPointQueue.isEmpty) return;

      final Paint linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2 * scaleInverse;

      String lastPointUuid = actionPointQueue.last;
      Offset lastPoint = toolData.points[lastPointUuid]!;
      canvas.drawLine(lastPoint, activeEffectivePointer!, linePaint);

      if (actionPointQueue.length <= 1) return;

      String secondLastPointUuid = actionPointQueue.secondLast;
      Offset secondLastPoint = toolData.points[secondLastPointUuid]!;
      Offset direction = lastPoint - secondLastPoint;
      Offset normalized = direction / direction.distance;

      drawConfirmationMarker(canvas, lastPoint, normalized);
    }
  }

  void drawHighestLayer(Canvas canvas) {
    while (highestLayer.isNotEmpty) {
      Function(Canvas) function = highestLayer.removeFirst();
      function(canvas);
    }
  }

  @override
  void paint(Canvas canvas, Size size) { // TODO get rid of all the null assertions by passing in the null-asserted values rather than using attributes
    registerDataOutput();

    establishGrid(canvas);
    establishCenterMarkings(canvas);

    drawPoints(canvas);
    drawLines(canvas);

    drawEditToolPreview(canvas);
    establishMarker(canvas);

    drawHighestLayer(canvas);

    defaultDataOutput();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}