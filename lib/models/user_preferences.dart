import 'package:toolfoam/models/json_serializable.dart';
import 'package:units_converter/units_converter.dart';

class UserPreferences implements JsonSerializable {

  bool hasSeenOnboarding;
  EditorPreferences editorPreferences;

  UserPreferences({
    required this.hasSeenOnboarding,
    required this.editorPreferences
  });

  factory UserPreferences.defaultSettings() {
    // TODO logic for setting default units and other presents to local specific values
    return UserPreferences(
      hasSeenOnboarding: false,
      editorPreferences: EditorPreferences(defaultUnit: LENGTH.meters)
    );
  }

  UserPreferences.fromJson(Map<String, dynamic> json) :
    hasSeenOnboarding = json['hasSeenOnboarding'],
    editorPreferences = EditorPreferences.fromJson(json['editorPreferences']);

  @override
  Map<String, dynamic> toJson() => {
    'hasSeenOnboarding': hasSeenOnboarding,
    'editorPreferences': editorPreferences.toJson()
  };

}

class EditorPreferences implements JsonSerializable {

  LENGTH defaultUnit;

  EditorPreferences.fromJson(Map<String, dynamic> json) :
    defaultUnit = LENGTH.values.firstWhere((u) => u.name == json['defaultUnit']);

  EditorPreferences({required this.defaultUnit});

  @override
  Map<String, dynamic> toJson() => {
    'defaultUnit': defaultUnit.name
  };

}