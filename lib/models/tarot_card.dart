import 'dart:math';

class TarotCard {
  final String name;
  final String imagery;
  final String uprightMeaning;
  final String invertedMeaning;
  final bool isUpright;

  TarotCard({
    required this.name, 
    required this.imagery,
    required this.uprightMeaning,
    required this.invertedMeaning,
    required this.isUpright,
  });

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
