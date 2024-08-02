import 'package:toolfoam/models/tf_id.dart';

abstract class Identifiable {
  final TfId id;

  Identifiable({required this.id});
}

abstract class Entity extends Identifiable {
  Entity({required super.id});

  Future<void> create(String name);
  Future<bool> exists();
  Future<void> delete();
}

abstract class DiskIOEntity extends Entity {
  DiskIOEntity({required super.id});

  Future<void> push();
  Future<void> pull();
}
