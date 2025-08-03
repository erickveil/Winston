import 'package:flutter/material.dart';

class DrawButton extends StatelessWidget {
  final bool isLoading;
  final bool hasDrawnCard;
  final VoidCallback onPressed;

  const DrawButton({
    Key? key,
    required this.isLoading,
    required this.hasDrawnCard,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        child: Text(hasDrawnCard ? 'Draw Another Card' : 'Draw Card'),
      ),
    );
  }
}