import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/tarot_card.dart';
import 'services/tarot_service.dart';

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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        // Card name (header)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _drawnCard!.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Card imagery
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _drawnCard!.imagery,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),

                        // Spacer ---------------------------------------------
                        const SizedBox(height: 16),


                        // Card orientation
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            // Change color based on orientation
                            color: _drawnCard!.isUpright
                              ? Colors.blue.shade50
                              : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: _drawnCard!.isUpright
                                ? Colors.blue.shade200
                                : Colors.orange.shade200
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _drawnCard!.isUpright 
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                                color: _drawnCard!.isUpright 
                                  ? Colors.blue 
                                  : Colors.orange
                              ),

                              // Row Spacer
                              const SizedBox(width: 8),

                              Text(
                                _drawnCard!.orientation,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _drawnCard!.isUpright 
                                    ? Colors.blue.shade700 
                                    : Colors.orange.shade700
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Spacer ---------------------------------------------
                        const SizedBox(height: 16),

                        // Card meaning
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meanings:',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              // Text Spacer
                              const SizedBox(height: 8),

                              Text(
                                _drawnCard!.meaning,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
