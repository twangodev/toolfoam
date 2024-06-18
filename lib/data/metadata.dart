class Metadata {

  DateTime createdAt;
  DateTime lastUpdate;

  Metadata(this.createdAt, this.lastUpdate);

  Metadata.empty() : createdAt = DateTime.now(), lastUpdate = DateTime.now();

  Metadata.fromJson(Map<String, dynamic> json) :
    createdAt = DateTime.parse(json['createdAt']),
    lastUpdate = DateTime.parse(json['lastChanged']);

  Map<String, dynamic> toJson() => {
    'createdAt': createdAt.toIso8601String(),
    'lastChanged': lastUpdate.toIso8601String()
  };

}
