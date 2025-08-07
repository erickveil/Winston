import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/tarot_card.dart';
import 'card_index_service.dart';

class TarotService {
  static final Random _random = Random();
  static CardIndexService? _cardIndexService;

  /// Load all tarot cards from JSON
  /// Returns a list of dynamic maps representing the cards.
  static Future<List<dynamic>> loadTarotCards() async {
    final String response = await rootBundle.loadString('assets/tarotData.json');
    return json.decode(response);
  }

  static void setCardIndexService(CardIndexService service) {
    _cardIndexService = service;
  }

  /// Draw a random card
  /// Returns a randomly drawn TarotCard instance.
  static Future<TarotCard> drawRandomCard() async {
    final cards = await loadTarotCards();
    final int randomIndex = _random.nextInt(cards.length);
    final bool isUpright = _random.nextBool();

    // Create the card model
    final cardData = cards[randomIndex];
    final card = TarotCard.fromJson(cardData, isUpright);

    // Add the image to the card model
    if (_cardIndexService != null) {
      final imagePath = _cardIndexService!.getImagePathForCard(card.name);
      if (imagePath != null) {
        card.imagePath = imagePath;
      }

    }

    return card;
  }

}