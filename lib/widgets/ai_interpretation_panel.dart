import 'package:flutter/material.dart';
import '../models/tarot_card.dart';
import '../services/ai_service.dart';

/// Widget for displaying AI-powered tarot card interpretation
class AiInterpretationPanel extends StatefulWidget {
  final TarotCard card;
  final TextEditingController questionController;

  const AiInterpretationPanel({
    super.key,
    required this.card,
    required this.questionController,
  });

  @override
  State<AiInterpretationPanel> createState() => _AiInterpretationPanelState();
}

class _AiInterpretationPanelState extends State<AiInterpretationPanel> {
  final AiService _aiService = AiService();
  
  String? _aiInterpretation;
  bool _isLoadingInterpretation = false;
  String? _errorMessage;

  @override
  void dispose() {
    super.dispose();
  }

  /// Generates an AI interpretation based on the card and user's question
  Future<void> _generateInterpretation() async {
    if (widget.questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question or scenario')),
      );
      return;
    }

    setState(() {
      _isLoadingInterpretation = true;
      _errorMessage = null;
    });

    try {
      final systemPrompt = '''You are an experienced and insightful tarot card reader and psychic medium. 
Your role is to provide meaningful, thoughtful interpretations of tarot cards in the context of a person's question or situation.
Consider the card's symbolism, its orientation (upright or inverted), and the traditional meanings provided.
Offer guidance that is compassionate, helpful, and thought-provoking.
Keep your interpretation between 2-4 paragraphs.''';

      final userMessage = '''Please interpret this tarot card reading for me:

Card: ${widget.card.name}
Orientation: ${widget.card.orientation}
Card Meaning: ${widget.card.meaning}
Card Imagery: ${widget.card.imagery}

My Question/Situation: ${widget.questionController.text}

Please provide a meaningful interpretation that connects the card's symbolism to my situation.''';

      final interpretation = await _aiService.sendMessage(
        systemMessage: systemPrompt,
        userMessage: userMessage,
        temperature: 0.7,
      );

      if (mounted) {
        setState(() {
          _aiInterpretation = interpretation;
          _isLoadingInterpretation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error generating interpretation: $e';
          _isLoadingInterpretation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Button to generate AI interpretation
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoadingInterpretation ? null : _generateInterpretation,
            icon: _isLoadingInterpretation
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.auto_fix_high),
            label: Text(
              _isLoadingInterpretation 
                ? 'Generating Interpretation...' 
                : 'Get AI Interpretation',
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Output section for AI interpretation
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ],
            ),
          ),

        if (_aiInterpretation != null && _errorMessage == null)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interpretation:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  child: Text(
                    _aiInterpretation!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),

        if (_aiInterpretation == null && _errorMessage == null && !_isLoadingInterpretation)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                'Click "Get AI Interpretation" to receive guidance',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
