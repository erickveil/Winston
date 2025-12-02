import 'dart:math';

import 'package:flutter/material.dart';

import 'models/config.dart';
import 'models/tarot_card.dart';
import 'services/card_index_service.dart';
import 'services/tarot_service.dart';
import 'widgets/ai_interpretation_panel.dart';
import 'widgets/card_display.dart';
import 'widgets/draw_button.dart';
import 'widgets/settings_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load saved config
  final config = Config();
  await config.loadFromPrefs();
  
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
  
  // Controller for the user's question that persists across card draws
  late TextEditingController _questionController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

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

            // Question input section - always visible at the top
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Question or Situation:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionController,
                    maxLines: 4,
                    minLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Enter your question or describe your situation...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Show a message when no card is drawn
            if(_drawnCard == null && !_isLoading)
              Expanded (
                child: Center(
                  child: Text(
                    'Press the button below to draw a tarot card.',
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

            // Card display section - shown when a card is drawn
            if (_drawnCard != null && !_isLoading)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TarotCardDisplay(card: _drawnCard!),
                      const SizedBox(height: 24),
                      // Pass the question controller to the interpretation panel
                      AiInterpretationPanel(
                        card: _drawnCard!,
                        questionController: _questionController,
                      ),
                    ],
                  ),
                ),
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
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
              child: const SettingsForm(),
            ),
          ),
          actions:const [ ],
        );
      },
    );
  }
}
