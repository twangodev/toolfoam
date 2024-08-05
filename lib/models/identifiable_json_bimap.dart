import 'package:flutter/material.dart';
import 'package:quiver/collection.dart';
import 'package:toolfoam/models/json_serializable.dart';
import 'package:toolfoam/models/tf_id.dart';

abstract class IdentifiableJsonBiMap<T extends JsonSerializable>
    implements JsonSerializable {
  @protected
  final HashBiMap<TfId, T> map = HashBiMap();

  IdentifiableJsonBiMap();

  Iterable<TfId> get ids => map.keys;
  Iterable<T> get values => map.values;
  Iterable<MapEntry<TfId, T>> get entries => map.entries;

  bool containsKey(TfId id) => map.containsKey(id);
  bool containsValue(T value) => map.containsValue(value);

  TfId add(T value) {
    TfId? id = map.inverse[value];
    if (id != null) {
      return id;
    }

    id = TfId.unique();
    map[id] = value;
    return id;
  }

  T? operator [](TfId id) => map[id];

  void operator []=(TfId id, T value) => map[id] = value;

  T? remove(TfId id) => map.remove(id);

  TfId? getId(T value) => map.inverse[value];

  MapEntry<String, dynamic> _transform(TfId id, T value) {
    return MapEntry(id.toString(), value.toJson());
  }

  @override
  Map<String, dynamic> toJson() {
    return map.map(_transform);
  }
}
