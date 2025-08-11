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

  void updateConfig({String? url, String? authorization, String? model}) {
    if (url != null) {
      this.url = url;
    }
    if (authorization != null) {
      this.authorization = authorization;
    }
    if (model != null) {
      this.model = model;
    }
  }

}