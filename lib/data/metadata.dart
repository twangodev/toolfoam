class Metadata {

  bool starred;

  DateTime createdAt;
  DateTime lastUpdate;

  Metadata(this.starred, this.createdAt, this.lastUpdate);

  Metadata.empty() : starred = false, createdAt = DateTime.now(), lastUpdate = DateTime.now();

  Metadata.fromJson(Map<String, dynamic> json)
      : starred = json['starred'] as bool,
        createdAt = DateTime.parse(json['createdAt']),
        lastUpdate = DateTime.parse(json['lastChanged']);

  Map<String, dynamic> toJson() => {
    'starred': starred,
    'createdAt': createdAt.toIso8601String(),
    'lastChanged': lastUpdate.toIso8601String()
  };

}
