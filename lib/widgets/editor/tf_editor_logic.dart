import 'dart:ui';

class TfEditorLogic {
  static bool interceptsSquare(Offset parent, Offset child, double size) {
    Rect rect = Rect.fromCenter(center: parent, width: size, height: size);
    return rect.contains(child);
  }

  static bool interceptsCircle(Offset parent, Offset child, double radius) {
    double distance = (parent - child).distanceSquared;
    return distance < radius * radius;
  }
}
