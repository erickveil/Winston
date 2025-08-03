import 'dart:math';

import 'package:flutter/material.dart';

import 'models/tarot_card.dart';
import 'services/tarot_service.dart';
import 'widgets/card_display.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Winston Tarot Medium',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Winston Tarot Medium'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TarotCard? _drawnCard;
  bool _isLoading = false;
  final Random _random = Random();

  // Draw a random tarot card
  Future<void> _drawCard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final card = await TarotService.drawRandomCard();
      setState(() {
        _drawnCard = card;
        _isLoading = false;
      });
      
    } catch(e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading tarot cards: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            // Show a message when no card is drawn
            if(_drawnCard == null && !_isLoading)
              // Expanded will fill the available space of the column
              Expanded (
                // This will center the content vertically and horizontally
                child: Center(
                  child: Text(
                    'Press the button to draw a tarot card.',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // loading indicator. Shown only when loading.
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            // Card display secion - shown when a card is drawn
            if (_drawnCard != null && !_isLoading)
              Expanded(
                child: TarotCardDisplay(card: _drawnCard!),
              ),

            // Draw Button
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _drawCard,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text(_drawnCard == null ? 'Draw Card' : 'Draw Another Card'),
              ),
            )

          ],
        ),
      ),
    );
  }
}
