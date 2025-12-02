

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
  
  // Selected mode
  late String _selectedMode;
  
  bool _isSaving = false;

  // Initialize controllers with current values
  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _config.url);
    _authController = TextEditingController(text: _config.authorization);
    _modelController = TextEditingController(text: _config.model);
    _selectedMode = _config.selectedMode;
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
  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        await _config.updateConfig(
          url: _urlController.text,
          authorization: _authController.text,
          model: _modelController.text,
          selectedMode: _selectedMode,
        );

        // Close the dialog
        if (mounted) Navigator.of(context).pop();

        // Show confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings saved')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving settings: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mode selector
          DropdownButtonFormField<String>(
            value: _selectedMode,
            decoration: const InputDecoration(
              labelText: 'Mode',
              hintText: 'Select the app mode',
            ),
            items: Config.modes.keys.map((String mode) {
              return DropdownMenuItem<String>(
                value: mode,
                child: Text(_getModeLabel(mode)),
              );
            }).toList(),
            onChanged: (String? newMode) {
              if (newMode != null) {
                setState(() {
                  _selectedMode = newMode;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          
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
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _authController,
            decoration: const InputDecoration(
              labelText: 'API Key',
              hintText: 'Enter the Open AI API key',
              helperText: 'Leave blank for local Ollama or similar services',
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
                onPressed: _isSaving ? null : _saveSettings,
                child: _isSaving 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  : const Text('SAVE'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _getModeLabel(String mode) {
    switch (mode) {
      case 'tarot_reading':
        return 'Tarot Card Reading';
      case 'ttrpg_scene':
        return 'TTRPG Scene Generator';
      case 'npc_creator':
        return 'NPC Creator';
      case 'dungeon_room':
        return 'Dungeon Room Generator';
      default:
        return mode;
    }
  }


}