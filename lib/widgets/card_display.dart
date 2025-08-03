import 'package:flutter/material.dart';
import '../models/tarot_card.dart';

class TarotCardDisplay extends StatelessWidget {
  final TarotCard card;
  
  const TarotCardDisplay({
    Key? key,
    required this.card,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card name (header)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              card.name,
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
                  card.imagery,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Card orientation
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: card.isUpright
                ? Colors.blue.shade50
                : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: card.isUpright
                  ? Colors.blue.shade200
                  : Colors.orange.shade200
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  card.isUpright 
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                  color: card.isUpright 
                    ? Colors.blue 
                    : Colors.orange
                ),
                const SizedBox(width: 8),
                Text(
                  card.orientation,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: card.isUpright 
                      ? Colors.blue.shade700 
                      : Colors.orange.shade700
                  ),
                ),
              ],
            ),
          ),

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
                const SizedBox(height: 8),
                Text(
                  card.meaning,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}