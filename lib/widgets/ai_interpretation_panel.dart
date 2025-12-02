import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tarot_card.dart';
import '../models/config.dart';
import '../services/ai_service.dart';

/// Widget for displaying AI-powered tarot card interpretation
class AiInterpretationPanel extends StatefulWidget {
  final TarotCard card;
  final TextEditingController questionController;
  final String? interpretation;
  final Function(String) onInterpretationGenerated;

  const AiInterpretationPanel({
    super.key,
    required this.card,
    required this.questionController,
    required this.interpretation,
    required this.onInterpretationGenerated,
  });

  @override
  State<AiInterpretationPanel> createState() => _AiInterpretationPanelState();
}

class _AiInterpretationPanelState extends State<AiInterpretationPanel> {
  final AiService _aiService = AiService();
  final Config _config = Config();
  
  bool _isLoadingInterpretation = false;
  String? _errorMessage;

  @override
  void dispose() {
    super.dispose();
  }

  /// Copy the interpretation to clipboard
  void _copyToClipboard() {
    if (widget.interpretation != null) {
      Clipboard.setData(ClipboardData(text: widget.interpretation!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interpretation copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
      final systemPrompt = _config.getCurrentSystemPrompt();

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
          _isLoadingInterpretation = false;
        });
        // Notify parent that interpretation was generated
        widget.onInterpretationGenerated(interpretation);
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
        // Button to generate AI interpretation - only show if no interpretation yet
        if (widget.interpretation == null && !_isLoadingInterpretation)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoadingInterpretation ? null : _generateInterpretation,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Get AI Interpretation'),
            ),
          ),

        // Loading indicator
        if (_isLoadingInterpretation)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              label: const Text('Generating Interpretation...'),
            ),
          ),

        if (_isLoadingInterpretation || widget.interpretation != null)
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

        if (widget.interpretation != null && _errorMessage == null)
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Interpretation:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.content_copy),
                      tooltip: 'Copy to clipboard',
                      onPressed: _copyToClipboard,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  child: SelectableText(
                    widget.interpretation!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
