import 'json_serializable.dart';

class Metadata implements JsonSerializable {

  String? name;
  DateTime createdAt;
  DateTime lastModified;

  Metadata({required this.name, required this.createdAt, required this.lastModified});

  factory Metadata.name(String? name) {
    DateTime now = DateTime.now();
    return Metadata(name: name, createdAt: now, lastModified: now);
  }

  factory Metadata.empty() {
    return Metadata.name(null);
  }

  Metadata.fromJson(Map<String, dynamic> json) :
    name = json['name'],
    createdAt = DateTime.parse(json['createdAt']),
    lastModified = DateTime.parse(json['lastModified']);

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'lastModified': lastModified.toIso8601String()
  };

}
