import 'package:flutter/material.dart';

@immutable
class Line {
  final String point1;
  final String point2;

  const Line(this.point1, this.point2);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Line) return false;
    bool directlyEqual = point1 == other.point1 && point2 == other.point2;
    bool reverseEqual = point1 == other.point2 && point2 == other.point1;
    return directlyEqual || reverseEqual;
  }

  @override
  int get hashCode => point1.hashCode * point2.hashCode;

  @override
  String toString() => 'Line($point1, $point2)';

  Iterable<String> toJson() sync* {
    yield point1;
    yield point2;
  }

  factory Line.fromJson(Iterable json) {
    Iterator iterator = json.iterator;
    return Line(iterator.current as String,
        iterator.moveNext() ? iterator.current as String : '');
  }
}
