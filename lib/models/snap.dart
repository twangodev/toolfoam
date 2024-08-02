import 'dart:ui';

import 'package:toolfoam/models/tf_id.dart';

enum SnapTarget implements Comparable<SnapTarget> {
  point(2),

  line(1),

  grid(0),
  ;

  final int priority;

  const SnapTarget(this.priority);

  @override
  int compareTo(SnapTarget other) {
    return priority.compareTo(other.priority);
  }
}

class Snap implements Comparable<Snap> {
  final SnapTarget target;
  final TfId? id;
  final Offset point;
  final double distanceSquared;

  Snap.point(this.point, this.distanceSquared, this.id)
      : target = SnapTarget.point;
  Snap.line(this.point, this.distanceSquared, this.id)
      : target = SnapTarget.line;
  Snap.grid(this.point, this.distanceSquared)
      : target = SnapTarget.grid,
        id = null;

  @override
  int compareTo(Snap other) {
    if (target != other.target) {
      return -target.compareTo(other.target);
    }
    return distanceSquared.compareTo(other.distanceSquared);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Snap) return false;
    return target == other.target && id == other.id && point == other.point;
  }

  @override
  int get hashCode => target.hashCode * id.hashCode * point.hashCode;

  @override
  String toString() {
    return 'Snap{target: $target, id: $id, point: $point, distanceSquared: $distanceSquared}';
  }

  bool operator <(Snap other) => compareTo(other) < 0;
  bool operator <=(Snap other) => compareTo(other) <= 0;
  bool operator >(Snap other) => compareTo(other) > 0;
  bool operator >=(Snap other) => compareTo(other) >= 0;

  static Snap min(Snap a, Snap b) => a < b ? a : b;
}
