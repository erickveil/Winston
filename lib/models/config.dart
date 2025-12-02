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
  String selectedMode = 'tarot_reading';

  // Storage keys
  static const String _urlKey = 'config_url';
  static const String _authKey = 'config_authorization';
  static const String _modelKey = 'config_model';
  static const String _modeKey = 'config_mode';

  // Define available modes with their system prompts
  static const Map<String, String> modes = {
    'tarot_reading': 'You are an experienced and insightful tarot card reader and psychic medium. \nYour role is to provide meaningful, thoughtful interpretations of tarot cards in the context of a person\'s question or situation.\nConsider the card\'s symbolism, its orientation (upright or inverted), and the traditional meanings provided.\nOffer guidance that is compassionate, helpful, and thought-provoking.\nKeep your interpretation between 2-4 paragraphs.',
    
    'ttrpg_scene': 'You are a creative game master for a solo TTRPG using tarot cards as narrative generators. \nYour role is to create immersive, exciting scene descriptions that incorporate the tarot card drawn as a narrative element.\nConsider the card\'s symbolism and meaning as plot hooks, environmental details, or encounters.\nCreate vivid descriptions that inspire storytelling and adventure.\nKeep your response to 3-5 paragraphs with enough detail to inspire gameplay.',
    
    'npc_creator': 'You are a creative character designer for tabletop RPGs. \nYour role is to create compelling NPC personalities, backstories, and motivations based on tarot card draws.\nUse the card\'s symbolism to inform character traits, secrets, and relationships.\nCreate characters that are interesting, believable, and ready to interact with player characters.\nProvide 2-4 paragraphs covering personality, background, and current goals.',
    
    'dungeon_room': 'You are a creative dungeon designer for tabletop RPGs. \nYour role is to generate immersive room descriptions and encounters for dungeons using tarot cards as inspiration.\nUse the card\'s imagery and meaning to inform the room\'s appearance, hazards, treasures, and inhabitants.\nCreate descriptions that are vivid, atmospheric, and mechanically interesting.\nKeep your response to 3-4 paragraphs with enough detail for a game master to run the encounter.',
  };

  /// Load saved values from SharedPreferences
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    url = prefs.getString(_urlKey) ?? url;
    authorization = prefs.getString(_authKey) ?? authorization;
    model = prefs.getString(_modelKey) ?? model;
    selectedMode = prefs.getString(_modeKey) ?? selectedMode;
  }

  /// Save current values to SharedPreferences
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_urlKey, url);
    await prefs.setString(_authKey, authorization);
    await prefs.setString(_modelKey, model);
    await prefs.setString(_modeKey, selectedMode);
  }

  /// Update config and save changes to persistent storage
  Future<void> updateConfig({
    String? url, 
    String? authorization, 
    String? model,
    String? selectedMode,
  }) async {
    if (url != null) this.url = url;
    if (authorization != null) this.authorization = authorization;
    if (model != null) this.model = model;
    if (selectedMode != null) this.selectedMode = selectedMode;
    
    // Save changes to persistent storage
    await saveToPrefs();
  }

  /// Get the system prompt for the current mode
  String getCurrentSystemPrompt() {
    return modes[selectedMode] ?? modes['tarot_reading']!;
  }

}