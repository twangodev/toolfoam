import 'package:uuid/uuid.dart';

abstract class Entity {
  static const uuidGenerator = Uuid();

  final String uuid;

  Entity({required this.uuid});

  Future<void> create(String name);
  Future<bool> exists();
  Future<void> delete();
}

abstract class DiskIOEntity extends Entity {
  DiskIOEntity({required super.uuid});

  Future<void> push();
  Future<void> pull();
}
