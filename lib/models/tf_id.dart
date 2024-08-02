import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// A class that wraps a `String` value around a UUID.
///
/// The `TfId` class is immutable and provides a unique identifier
/// using the UUID version 4 format.
///
/// Example usage:
/// ```dart
/// final id = TfId.unique();
/// print(id); // Outputs a unique UUID string
/// ```
@immutable
class TfId {
  static const _generator = Uuid();

  final String _value;

  TfId(this._value) : assert(_value.isNotEmpty, 'Identifier cannot be empty');

  factory TfId.unique() {
    return TfId(_generator.v4());
  }

  @override
  bool operator ==(Object other) {
    if (other is TfId) {
      return _value == other._value;
    }
    return false;
  }

  @override
  int get hashCode {
    return _value.hashCode;
  }

  @override
  String toString() {
    return _value;
  }
}
