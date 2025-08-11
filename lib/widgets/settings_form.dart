

import 'package:flutter/material.dart';

import '../models/config.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  late TextEditingController _urlController;
  late TextEditingController _authController;
  late TextEditingController _modelController;

  // Config instance
  final Config _config = Config();

  // Initialize controllers with current values
  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _config.url);
    _authController = TextEditingController(text: _config.authorization);
    _modelController = TextEditingController(text: _config.model);
  }

  // Clean up controllers
  @override
  void dispose() {
    _urlController.dispose();
    _authController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  // Save Settings
  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      _config.updateConfig(
        url: _urlController.text,
        authorization: _authController.text,
        model: _modelController.text,
      );

      // Close the dialog
      Navigator.of(context).pop();

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'API URL',
              hintText: 'Enter the URL for the LLM',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a URL';
              }
              // TODO: Do we need URL validation?
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _authController,
            decoration: const InputDecoration(
              labelText: 'API Key',
              hintText: 'Enter the Open AI API key',
            ),
            obscureText: true,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _modelController,
            decoration: const InputDecoration(
              labelText: 'Model Name',
              hintText: 'Enter the model name (e.g., gpt-4.1-nano)',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a model name';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('SAVE'),
              ),
            ],
          ),
        ],
      ),
    );
  }


}