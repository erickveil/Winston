import 'dart:math';

import 'package:flutter/material.dart';

import 'models/tarot_card.dart';
import 'services/card_index_service.dart';
import 'services/tarot_service.dart';
import 'widgets/card_display.dart';
import 'widgets/draw_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final  cardIndexService = await CardIndexService.initialize();
  TarotService.setCardIndexService(cardIndexService);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              _showSettingsDialog(context);
            },
          ),
        ]
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

            // Button for drawing a card
            DrawButton(
              isLoading: _isLoading,
              hasDrawnCard: _drawnCard != null,
              onPressed: _drawCard,
            ),

          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: const Text('Settings dialog content goes here.'),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
