import 'package:toolfoam/geometry/segment.dart';
import 'package:toolfoam/models/identifiable_json_map.dart';
import 'package:toolfoam/models/tf_id.dart';

class LineData extends IdentifiableJsonHashMap<Segment> {
  Iterable<TfId> dependsOn(TfId id) {
    return map.entries
        .where((entry) => entry.value.contains(id))
        .map((entry) => entry.key);
  }
}
