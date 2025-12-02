import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/config.dart';

/// Service class for communicating with LLM APIs
class AiService {
  final Config _config = Config();

  /// Sends a message to the LLM and returns the assistant's response
  /// 
  /// [systemMessage] - The system prompt that defines the AI's behavior
  /// [userMessage] - The user's request or question
  /// 
  /// Returns the assistant's response text
  /// Throws an exception if the request fails
  Future<String> sendMessage({
    required String systemMessage,
    required String userMessage,
    double temperature = 1.0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_config.url),
        headers: {
          'Content-Type': 'application/json',
          if (_config.authorization.isNotEmpty)
            'Authorization': 'Bearer ${_config.authorization}',
        },
        body: jsonEncode({
          'model': _config.model,
          'temperature': temperature,
          'stream': false,
          'messages': [
            {
              'role': 'system',
              'content': systemMessage,
            },
            {
              'role': 'user',
              'content': userMessage,
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Extract the assistant's response from the API response
        // This assumes a standard OpenAI-compatible API format
        final assistantMessage = jsonResponse['choices'][0]['message']['content'];
        return assistantMessage as String;
      } else {
        throw Exception(
          'Failed to get response from LLM. '
          'Status: ${response.statusCode}, '
          'Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error communicating with LLM: $e');
    }
  }

  /// Sends a message with custom parameters
  /// 
  /// [systemMessage] - The system prompt
  /// [userMessage] - The user's request
  /// [temperature] - Controls randomness (0.0 to 2.0, default 1.0)
  /// [maxTokens] - Optional maximum tokens in response
  /// 
  /// Returns the assistant's response text
  Future<String> sendMessageAdvanced({
    required String systemMessage,
    required String userMessage,
    double temperature = 1.0,
    int? maxTokens,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'model': _config.model,
        'temperature': temperature,
        'stream': false,
        'messages': [
          {
            'role': 'system',
            'content': systemMessage,
          },
          {
            'role': 'user',
            'content': userMessage,
          },
        ],
      };

      // Add max_tokens if provided
      if (maxTokens != null) {
        requestBody['max_tokens'] = maxTokens;
      }

      final response = await http.post(
        Uri.parse(_config.url),
        headers: {
          'Content-Type': 'application/json',
          if (_config.authorization.isNotEmpty)
            'Authorization': 'Bearer ${_config.authorization}',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final assistantMessage = jsonResponse['choices'][0]['message']['content'];
        return assistantMessage as String;
      } else {
        throw Exception(
          'Failed to get response from LLM. '
          'Status: ${response.statusCode}, '
          'Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error communicating with LLM: $e');
    }
  }

  /// Tests the connection to the LLM API with a simple request
  /// Useful for verifying settings are correct
  /// 
  /// Returns true if connection is successful, false otherwise
  Future<bool> testConnection() async {
    try {
      final response = await http.post(
        Uri.parse(_config.url),
        headers: {
          'Content-Type': 'application/json',
          if (_config.authorization.isNotEmpty)
            'Authorization': 'Bearer ${_config.authorization}',
        },
        body: jsonEncode({
          'model': _config.model,
          'temperature': 0.5,
          'stream': false,
          'messages': [
            {
              'role': 'user',
              'content': 'Hello',
            },
          ],
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
