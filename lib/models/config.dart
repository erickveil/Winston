import 'package:shared_preferences/shared_preferences.dart';

class Config {

  // Singleton
  static final Config _instance = Config._internal();

  factory Config() {
    return _instance;
  }

  Config._internal();

  // Properties
  String url = 'https://api.openai.com/v1/chat/completions';
  String authorization = '';
  String model = 'gpt-4.1-nano';

  // Storage keys
  static const String _urlKey = 'config_url';
  static const String _authKey = 'config_authorization';
  static const String _modelKey = 'config_model';

  /// Load saved values from SharedPreferences
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    url = prefs.getString(_urlKey) ?? url;
    authorization = prefs.getString(_authKey) ?? authorization;
    model = prefs.getString(_modelKey) ?? model;
  }

  /// Save current values to SharedPreferences
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_urlKey, url);
    await prefs.setString(_authKey, authorization);
    await prefs.setString(_modelKey, model);
  }

  /// Update config and save changes to persistent storage
  Future<void> updateConfig({String? url, String? authorization, String? model}) async {
    if (url != null) {
      this.url = url;
    }
    if (authorization != null) {
      this.authorization = authorization;
    }
    if (model != null) {
      this.model = model;
    }
    
    // Save changes to persistent storage
    await saveToPrefs();
  }

}