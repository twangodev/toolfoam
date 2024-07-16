import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:toolfoam/models/editing_tool.dart';
import 'package:toolfoam/widgets/editor/tf_editor_config.dart';
import 'package:toolfoam/widgets/editor/tf_editor_logic.dart';
import 'package:toolfoam/widgets/editor/tf_editor_painter_data.dart';
import 'package:vector_math/vector_math_64.dart' show Quad;

import '../../models/tools/tf_tool_data.dart';

class TFEditorPainter extends CustomPainter {

  final Quad viewport;
  final bool toggleGrid;
  final TFEditorData data;
  final EditingTool editingTool;

  static const Offset origin = Offset(0, 0);

  TFEditorPainter({
    required this.viewport,
    required this.data,
    required this.toggleGrid,
    required this.editingTool,
  });

  late final visibleRect = Rect.fromLTRB(viewport.point0.x, viewport.point0.y, viewport.point2.x, viewport.point2.y,);
  
  late final double scale = data.scale;
  late final double scaleInverse = data.scaleInverse;
  late final double effectiveGridSize = data.effectiveGridSize;
  late final int gridRatio = data.gridRatio;
  late final double gridSize = data.gridSize;
  late final Offset? activePointer = data.activePointer;
  late final Offset? nearestGridSnap = data.nearestGridSnap;
  late final bool? shouldSnapToGrid = data.shouldSnapToGrid;
  late final TFToolData? toolData = data.toolData;

  late final scaledVisibleRect = Rect.fromLTRB(
      (visibleRect.left / gridSize).floorToDouble(),
      (visibleRect.top / gridSize).ceilToDouble(),
      (visibleRect.right / gridSize).floorToDouble(),
      (visibleRect.bottom / gridSize).ceilToDouble(),
  );

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
      ..lineTo(-TFEditorConfig.ucsInnerRadius * scaleInverse, 0)
      ..arcToPoint(
        Offset(0, -TFEditorConfig.ucsInnerRadius * scaleInverse),
        radius: Radius.circular(TFEditorConfig.ucsInnerRadius * scaleInverse),
        clockwise: true,
      )
      ..close();

    Path bottomRight = Path()
      ..moveTo(0, 0)
      ..lineTo(TFEditorConfig.ucsInnerRadius * scaleInverse, 0)
      ..arcToPoint(
        Offset(0, TFEditorConfig.ucsInnerRadius * scaleInverse),
        radius: Radius.circular(TFEditorConfig.ucsInnerRadius * scaleInverse),
        clockwise: true,
      )
      ..close();

    canvas.drawCircle(origin, TFEditorConfig.ucsRadius * scaleInverse, grayUcsBackground);
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
      Paint selectedPaint = (i % TFEditorConfig.majorGridDensity == 0) ? majorGrid : minorGrid;
      canvas.drawLine(Offset(visibleRect.left, y), Offset(visibleRect.right, y), selectedPaint);
    }

    // Drawing vertical lines
    for (int i = scaledVisibleRect.left.toInt(); i <= scaledVisibleRect.right.toInt(); i++) {
      double x = i * gridSize;
      if (x == 0) continue;
      Paint selectedPaint = (i % TFEditorConfig.majorGridDensity == 0) ? majorGrid : minorGrid;
      canvas.drawLine(Offset(x, visibleRect.top), Offset(x, visibleRect.bottom), selectedPaint);
    }

  }

  void drawCrossMarker(Canvas canvas, Offset offset) {
    final Paint crosshairPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2 * scaleInverse
      ..style = PaintingStyle.stroke;

    double halfSize = TFEditorConfig.crossMarkerSize * scaleInverse / 2;

    canvas.drawLine(offset.translate(-halfSize, 0), offset.translate(halfSize, 0), crosshairPaint);
    canvas.drawLine(offset.translate(0, -halfSize), offset.translate(0, halfSize), crosshairPaint);

  }

  void drawSnapMarker(Canvas canvas, Offset offset) {
    final Paint snapPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.5 * scaleInverse
      ..style = PaintingStyle.stroke;

    double scaledSize = TFEditorConfig.defaultSnapTolerance * scaleInverse;
    Rect rect = Rect.fromCenter(center: offset, width: scaledSize, height: scaledSize);

    canvas.drawRect(rect, snapPaint);
  }

  void establishGridSnap(Canvas canvas) {
    if (shouldSnapToGrid!) {
      drawSnapMarker(canvas, nearestGridSnap!);
      drawCrossMarker(canvas, nearestGridSnap!);
    } else {
      drawCrossMarker(canvas, activePointer!);
    }
  }

  void establishMarker(Canvas canvas) {
  if (!editingTool.allowsMarker || activePointer == null) return;
    if (toolData != null && toolData!.points.contains(nearestGridSnap!)) {
      drawSnapMarker(canvas, nearestGridSnap!);
      return;
    }

    establishGridSnap(canvas);
  }

  void drawPoints(Canvas canvas) {
    if (toolData == null) {
      return;
    }

    final Paint fillPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2 * scaleInverse
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = Colors.grey.shade900
      ..strokeWidth = 2 * scaleInverse
      ..style = PaintingStyle.stroke;

    for (Offset point in toolData!.points) {
      canvas.drawCircle(point, TFEditorConfig.pointRadius * scaleInverse, fillPaint);
      canvas.drawCircle(point, TFEditorConfig.pointRadius * scaleInverse, strokePaint);
    }
  }


  @override
  void paint(Canvas canvas, Size size) {
    establishGrid(canvas);
    establishCenterMarkings(canvas);

    toolData!.points.add(Offset(100, 100));
    drawPoints(canvas);

    establishMarker(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}