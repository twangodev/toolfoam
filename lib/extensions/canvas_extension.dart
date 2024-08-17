import 'package:flutter/material.dart';

import '../geometry/fit_point_spline.dart';
import '../geometry/point.dart';
import '../widgets/editor/editor_config.dart';

extension CanvasExtension on Canvas {
  void drawPoint(Point point, double scaleInverse) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2 * scaleInverse
      ..style = PaintingStyle.fill;

    final Paint outlinePaint = Paint()
      ..color = Colors.grey.shade900
      ..strokeWidth = 2 * scaleInverse
      ..style = PaintingStyle.stroke;

    double radius = EditorConfig.pointRadius * scaleInverse;
    drawCircle(point.toOffset(), radius, paint);
    drawCircle(point.toOffset(), radius, outlinePaint);
  }

  // TODO figure out a way to draw the spline (auto resolving the Start/End points) - remove the parameters start and end
  void drawFitPointSpline(FitPointSpline spline, FixedPoint a, FixedPoint b,
      double scaleInverse, bool showControlPoints) {
    final Paint splinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2 * scaleInverse
      ..style = PaintingStyle.stroke;

    final Paint tangentHandleLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1 * scaleInverse
      ..style = PaintingStyle.stroke;

    List<VoidCallback> topLayer = [];

    Path path = Path();
    path.moveTo(a.x, a.y);
    FixedPoint aOut = a + spline.aRelativeOut;
    FixedPoint lastOut = aOut;

    topLayer.add(() {
      drawPoint(a, scaleInverse);

      drawPoint(aOut, scaleInverse);
      drawLine(a.toOffset(), aOut.toOffset(), tangentHandleLinePaint);
    });

    for (int i = 0; i < spline.controlPoints.length; i++) {
      ControlPoint current = spline.controlPoints[i];
      FixedPoint inTangent = current.inTangent;

      path.cubicTo(
          lastOut.x, lastOut.y, inTangent.x, inTangent.y, current.x, current.y);

      lastOut = current.outTangent;

      if (!showControlPoints) continue;

      FixedPoint outTangent = current.outTangent;
      topLayer.add(() {
        drawPoint(current, scaleInverse);

        drawPoint(inTangent, scaleInverse);
        drawPoint(outTangent, scaleInverse);
        drawLine(inTangent.toOffset(), outTangent.toOffset(),
            tangentHandleLinePaint);
      });
    }

    FixedPoint bIn = b + spline.bRelativeIn;

    path.cubicTo(lastOut.x, lastOut.y, bIn.x, bIn.y, b.x, b.y);

    topLayer.add(() {
      drawPoint(b, scaleInverse);

      drawPoint(bIn, scaleInverse);
      drawLine(b.toOffset(), bIn.toOffset(), tangentHandleLinePaint);
    });

    drawPath(path, splinePaint);

    for (VoidCallback action in topLayer) {
      action.call();
    }
  }
}
