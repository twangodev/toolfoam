import 'package:toolfoam/geometry/line.dart';
import 'package:toolfoam/models/identifiable_json_bimap.dart';
import 'package:toolfoam/models/tf_id.dart';

class LineData extends IdentifiableJsonBiMap<Line> {
  Iterable<TfId> dependsOn(TfId id) {
    return map.entries
        .where((entry) => entry.value.contains(id))
        .map((entry) => entry.key);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
