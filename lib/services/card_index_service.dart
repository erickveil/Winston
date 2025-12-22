
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/index_item.dart';

class CardIndexService {
  // A list of all indexed cards
  final List<IndexItem> _index = [];

  /// Adds a card to the index.
  void addCard(String imagePath, String jsonName) {
    _index.add(IndexItem(imagePath: imagePath, jsonName: jsonName));
  }

  /// Retrieves the index of cards.
  List<IndexItem> get index => _index;

  /// Initialize the card index service by loading images and JSON data
  /// This should be called during app startup
  static Future<CardIndexService> initialize() async {
    final service = CardIndexService();
    
    // Generate image paths programmatically since AssetManifest.json is not
    // reliably available in newer Flutter versions
    final imagePaths = _generateImagePaths();
    
    // Load JSON data
    final String jsonString = await rootBundle.loadString('assets/tarotData.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    
    // Build the index
    await service.buildIndex(imagePaths, jsonData);
    
    print('Card index built with ${service.index.length} matches');
    return service;
  }

  /// Generates the list of all 78 tarot card image paths
  /// This avoids dependency on AssetManifest.json which is not available in newer Flutter versions
  static List<String> _generateImagePaths() {
    const prefix = '0912190455860';
    final List<String> paths = [];
    
    // Major Arcana (0-21)
    final majorArcana = [
      '0_Fool', '1_Magician', '2_High_Priestess', '3_Empress', '4_Emperor',
      '5_Hierophant', '6_Lovers', '7_Chariot', '8_Strength', '9_Hermit',
      '10_Wheel_of_Fortune', '11_Justice', '12_Hanged_Man', '13_Death',
      '14_Temperance', '15_Devil', '16_Tower', '17_Star', '18_Moon',
      '19_Sun', '20_Judgement', '21_World'
    ];
    
    for (int i = 0; i < majorArcana.length; i++) {
      paths.add('assets/images/${prefix}_${i.toString().padLeft(2, '0')}_${majorArcana[i]}.jpg');
    }
    
    // Minor Arcana
    final suits = ['Wand', 'Cup', 'Sword', 'Pentacle'];
    final ranks = [
      '1', '2', '3', '4', '5', '6', '7', '8', '9', '10',
      'Page', 'Knight', 'Queen', 'King'
    ];
    
    int cardNumber = 22; // Start after major arcana
    for (final suit in suits) {
      for (final rank in ranks) {
        paths.add('assets/images/${prefix}_${cardNumber}_${suit}_$rank.jpg');
        cardNumber++;
      }
    }
    
    return paths;
  }

  /// Builds the card index by matching image filenames with their corresponding 
  /// JSON names.
  /// This should be called during app initialization.
  Future<void> buildIndex(List<String> imageFilePaths, List<dynamic> jsonData) async {
    _index.clear(); // Clear any existing index items

    for (final imagePath in imageFilePaths) {
      // Determine if this is a major arcana card
      bool isMajorCard = _isMajor(imagePath);
      String matchKey;
      
      if (isMajorCard) {
        // For major arcana cards, we match by ID (e.g., "fool", "wheel", etc.)
        matchKey = _extractImageMajorArcanaId(imagePath);
        
        // Find matching JSON card name
        for (final cardData in jsonData) {
          String jsonName = cardData['name'] as String;
          String jsonId = _extractJsonNameMajorArcanaId(jsonName);
          
          if (matchKey == jsonId) {
            _index.add(IndexItem(imagePath: imagePath, jsonName: jsonName));
            break;
          }
        }
      } else {
        // For minor arcana cards, match by suit and value
        String suit = _extractSuit(imagePath);
        int value = _extractImageMinorCardValue(imagePath);
        
        // Find matching JSON card name
        for (final cardData in jsonData) {
          String jsonName = cardData['name'] as String;
          
          if (_extractSuit(jsonName) == suit && 
              _extractJsonNameCardValue(jsonName) == value) {
            _index.add(IndexItem(imagePath: imagePath, jsonName: jsonName));
            break;
          }
        }
      }
    }
  }

  /// Gets the image path for a given card name from the JSON
  String? getImagePathForCard(String jsonCardName) {
    for (final item in _index) {
      if (item.jsonName == jsonCardName) {
        return item.imagePath;
      }
    }
    return null;
  }

  /// Gets the card data (JSON name) for a given image path
  String? getCardNameForImage(String imagePath) {
    for (final item in _index) {
      if (item.imagePath == imagePath) {
        return item.jsonName;
      }
    }
    return null;
  }

  /// Private method that extracts the suit of the card from the provided string.
  /// This works for both image file names and JSON object names.
  String _extractSuit(String cardName) {
    final lowerName = cardName.toLowerCase();
    if (lowerName.contains('cup')) return 'cups';
    if (lowerName.contains('wand')) return 'wands';
    if (lowerName.contains('sword')) return 'swords';
    if (lowerName.contains('pentacle')) return 'pentacles';
    return 'major';
  }

  /// Determines if the card is major arcana or not.
  /// Works for both image file names and JSON object names
  bool _isMajor(String cardName) {
    String suit = _extractSuit(cardName);
    return suit == "major";
  }

  /// Determines the value of the card represented in the image if it is 
  /// minor arcana.
  /// Only works for image file names.
  /// Returns numeric values for ace and face cards.
  /// Returns 0 for major arcana cards.
  int _extractImageMinorCardValue(String imageName) {

    if (_isMajor(imageName)) {
      return 0;
    }

    // For minor arcana cards
    // Convert to lowercase to handle any case variations
    final lowerName = imageName.toLowerCase();
    
    // Check for court cards first
    if (lowerName.contains('page')) return 11;
    if (lowerName.contains('knight')) return 12;
    if (lowerName.contains('queen')) return 13;
    if (lowerName.contains('king')) return 14;

    // For number cards, extract the number
    // First, get the filename part (in case a full path is provided)
    final fileName = imageName.split('/').last;
    
    // Find the pattern that matches the number followed by a suit
    // Example: "0912190455860_29_Wand_8.jpg" - we need to extract "8"
    final regex = RegExp(r'_(\d+)\.jpg$');
    final match = regex.firstMatch(fileName);
  
    if (match != null && match.groupCount >= 1) {
      // Parse the number and return it
      return int.tryParse(match.group(1)!) ?? 0;
    }

    return 0;
  }

  /// Determines the numeric value of minor arcana cards.
  /// Only works for JSON object card names.
  /// Ace and face cards are returned as numeric values.
  /// Major arcana cards are returned as 0.
  int _extractJsonNameCardValue(String cardName) {

    if (_isMajor(cardName)) {
      return 0;
    }

    // For minor arcana cards
    final lowerName = cardName.toLowerCase();
    
    // Check for court cards
    if (lowerName.contains('page')) return 11;
    if (lowerName.contains('knight')) return 12;
    if (lowerName.contains('queen')) return 13;
    if (lowerName.contains('king')) return 14;
    
    // Check for specific number words
    if (lowerName.startsWith('ace')) return 1;
    if (lowerName.startsWith('two')) return 2;
    if (lowerName.startsWith('three')) return 3;
    if (lowerName.startsWith('four')) return 4;
    if (lowerName.startsWith('five')) return 5;
    if (lowerName.startsWith('six')) return 6;
    if (lowerName.startsWith('seven')) return 7;
    if (lowerName.startsWith('eight')) return 8;
    if (lowerName.startsWith('nine')) return 9;
    if (lowerName.startsWith('ten')) return 10;

    // major arcana
    return 0;
  }

  /// Gets an ID for major arcana cards
  /// Only works with image file names.
  String _extractImageMajorArcanaId(String imageFileName) {

    if (!_isMajor(imageFileName)) {
      return '';
    }

    // Get just the file name without path
    final fileName = imageFileName.split('/').last;
    
    // Split the filename by underscores
    final parts = fileName.split('_');
    
    // If there aren't enough parts, return empty
    if (parts.length < 4) {
      return '';
    }
    
    // Special cases based on your examples
    final lowerFileName = fileName.toLowerCase();
    
    if (lowerFileName.contains('wheel_of_fortune')) {
      return 'wheel';
    }
    if (lowerFileName.contains('hanged_man')) {
      return 'hanged';
    }
    if (lowerFileName.contains('high_priestess')) {
      return 'priestess';
    }
    
    // For cases like "Justice", "Death", "Temperance", "Judgement" where we 
    //want the whole word
    // Get the last part before the extension that isn't a number
    for (int i = parts.length - 1; i >= 0; i--) {
      final part = parts[i].split('.')[0]; // Remove extension if present
      
      // If it's a word (not just a number) and not "of" or "the"
      if (part.isNotEmpty && 
          !RegExp(r'^\d+$').hasMatch(part) &&
          !['of', 'the'].contains(part.toLowerCase())) {
        return part.toLowerCase();
      }
    }
    
    // If we can't determine the ID, return empty string
    return '';
  }

  /// Extracts the major arcana ID from the JSON object's name.
  /// Only works with the names from the JSON file.
  String _extractJsonNameMajorArcanaId(String jsonName) {

    // Return empty string if it's not a major arcana card
    if (!_isMajor(jsonName)) {
      return '';
    }
    
    final lowerName = jsonName.toLowerCase();
    
    // Special cases to match with image file IDs
    if (lowerName.contains('wheel')) {
      return 'wheel';
    }
    if (lowerName.contains('hanged')) {
      return 'hanged';
    }
    if (lowerName.contains('priestess')) {
      return 'priestess';
    }
    
    // For other cases, get the name without "the" prefix and articles
    String cleanName = lowerName
        .replaceAll('the ', '')
        .replaceAll(' of ', ' ')
        .trim();
    
    // If there are multiple words, take the first substantive word
    List<String> words = cleanName.split(' ');
    if (words.isNotEmpty) {
      return words[0];
    }
    
    // Default to empty string if we can't determine the ID
    return '';
  }

}