import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:quiver/collection.dart';
import 'package:toolfoam/models/json_serializable.dart';
import 'package:toolfoam/models/tf_id.dart';

abstract class IdentifiableJsonMap<T extends JsonSerializable>
    implements JsonSerializable {
  @protected
  abstract final Map<TfId, T> map;

  IdentifiableJsonMap();

  Iterable<TfId> get ids => map.keys;
  Iterable<T> get values => map.values;
  Iterable<MapEntry<TfId, T>> get entries => map.entries;

  bool containsKey(TfId id) => map.containsKey(id);
  bool containsValue(T value) => map.containsValue(value);

  TfId add(T value) {
    TfId? id = getId(value);
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

  TfId? getId(T value) {
    for (MapEntry entry in map.entries) {
      TfId id = entry.key;
      T v = entry.value;

      if (value == v) return id;
    }
    return null;
  }

  void addDiff(IdentifiableJsonMap<T> other) {
    map.addEntries(other.map.entries);
    other.map.clear();
  }

  MapEntry<String, dynamic> _transform(TfId id, T value) {
    return MapEntry(id.toString(), value.toJson());
  }

  @override
  Map<String, dynamic> toJson() {
    return map.map(_transform);
  }
}

abstract class IdentifiableJsonHashMap<T extends JsonSerializable>
    extends IdentifiableJsonMap<T> {
  @override
  final HashMap<TfId, T> map = HashMap();
}

abstract class IdentifiableJsonBiMap<T extends JsonSerializable>
    extends IdentifiableJsonMap<T> {
  @override
  final BiMap<TfId, T> map = HashBiMap();

  @override
  TfId? getId(T value) {
    return map.inverse[value];
  }
}
