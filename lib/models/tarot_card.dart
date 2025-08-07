/// A model class representing a Tarot card with its properties.
class TarotCard {

  final String name;
  final String imagery;
  final String uprightMeaning;
  final String invertedMeaning;
  final bool isUpright;
  String? imagePath;

  TarotCard({
    required this.name, 
    required this.imagery,
    required this.uprightMeaning,
    required this.invertedMeaning,
    required this.isUpright,
    this.imagePath,
  });

  /// Factory constructor to create a TarotCard instance from JSON data.
  /// [json] is a map containing the card data.
  /// [isUpright] indicates whether the card is drawn upright or inverted.
  /// If a field is missing in the JSON, default values are provided.
  /// Returns a valid TarotCard instance.
  factory TarotCard.fromJson(Map<String, dynamic> json, bool isUpright) {
    return TarotCard(
      name: json['name'] ?? 'Unknown Card',
      imagery: json['imagery'] ?? 'No imagery description available.',
      uprightMeaning: json['uprightMeaning'] ?? 'No upright meaning available.',
      invertedMeaning: json['invertedMeaning'] ?? 'No inverted meaning available.',
      isUpright: isUpright,
    );
  }

  String get orientation => isUpright ? 'Upright' : 'Inverted';
  String get meaning => isUpright ? uprightMeaning : invertedMeaning;
}
