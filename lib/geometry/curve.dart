import 'package:toolfoam/models/json_serializable.dart';
import 'package:toolfoam/models/tf_id.dart';

abstract class Curve implements JsonSerializable {
  abstract TfId a;
  abstract TfId b;

  bool contains(TfId id) => id == a || id == b;
}
