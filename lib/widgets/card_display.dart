import 'package:flutter/material.dart';
import '../models/tarot_card.dart';

class TarotCardDisplay extends StatelessWidget {
  final TarotCard card;
  final Widget? interpretationPanel;
  
  const TarotCardDisplay({
    super.key,
    required this.card,
    this.interpretationPanel,
  });
  
  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card image on the left at 1/3 width
          Expanded(
            flex: 1,
            child: _buildCardImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardHeader(context),
                  _buildCardImagery(context),
                  const SizedBox(height: 16),
                  _buildCardOrientation(context),
                  const SizedBox(height: 16),
                  _buildCardMeaning(context),
                  if (interpretationPanel != null) ...[
                    const SizedBox(height: 24),
                    interpretationPanel!,
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      // Stacked layout for narrower screens
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCardHeader(context),
            const SizedBox(height: 16),
            // Card image centered
            SizedBox(
              height: 300,
              child: Center(
                child: _buildCardImage(),
              ),
            ),
            const SizedBox(height: 16),
            _buildCardImagery(context),
            const SizedBox(height: 16),
            _buildCardOrientation(context),
            const SizedBox(height: 16),
            _buildCardMeaning(context),
            if (interpretationPanel != null) ...[
              const SizedBox(height: 24),
              interpretationPanel!,
            ],
          ],
        ),
      );
    }
  }

  Widget _buildCardImage() {
    // No image path
    if (card.imagePath == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No Image Available'),
        ),
      );
    }

    // Image path in model
    return RotatedBox(
      quarterTurns: card.isUpright ? 0 : 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          card.imagePath!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        card.name,
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCardImagery(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildCardOrientation(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildCardMeaning(BuildContext context) {
    return Container(
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
    );
  }
  
}