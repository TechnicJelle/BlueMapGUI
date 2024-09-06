import "package:shared_preferences/shared_preferences.dart";

class Prefs {
  // == Constants ==
  static const String projectPathKey = "project_path";

  // == Static ==
  static late Prefs _instance;

  static Prefs get instance => _instance;

  // == Private Variables ==
  final SharedPreferences _prefs;

  // == Constructors ==
  Prefs._(this._prefs);

  // == Public Methods ==
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = Prefs._(prefs);
  }

  // == Getters and Setters ==
  String? get projectPath => _prefs.getString(projectPathKey);

  /// Set the project path. If `null`, the project path will be cleared.
  set projectPath(String? value) {
    if (value == null) {
      _prefs.remove(projectPathKey);
    } else {
      _prefs.setString(projectPathKey, value);
    }
  }
}
