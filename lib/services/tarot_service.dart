import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/tarot_card.dart';

class TarotService {
  static final Random _random = Random();

  /// Load all tarot cards from JSON
  /// Returns a list of dynamic maps representing the cards.
  static Future<List<dynamic>> loadTarotCards() async {
    final String response = await rootBundle.loadString('assets/tarotData.json');
    return json.decode(response);
  }

  /// Draw a random card
  /// Returns a randomly drawn TarotCard instance.
  static Future<TarotCard> drawRandomCard() async {
    final cards = await loadTarotCards();
    final int randomIndex = _random.nextInt(cards.length);
    final bool isUpright = _random.nextBool();
    return TarotCard.fromJson(cards[randomIndex], isUpright);
  }

}