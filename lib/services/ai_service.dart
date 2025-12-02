import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/config.dart';

/// Service class for communicating with LLM APIs
class AiService {
  final Config _config = Config();
  static const String _debugTag = '[AiService]';

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
      print('$_debugTag Preparing request to: ${_config.url}');
      print('$_debugTag Using model: ${_config.model}');
      
      final requestBody = {
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

      print('$_debugTag Request body:');
      print(jsonEncode(requestBody));

      final response = await http.post(
        Uri.parse(_config.url),
        headers: {
          'Content-Type': 'application/json',
          if (_config.authorization.isNotEmpty)
            'Authorization': 'Bearer ${_config.authorization}',
        },
        body: jsonEncode(requestBody),
      );

      print('$_debugTag Response status code: ${response.statusCode}');
      print('$_debugTag Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Handle both OpenAI and Ollama API formats
        String assistantMessage;
        
        // Try Ollama format first (message.content)
        if (jsonResponse['message'] != null && jsonResponse['message']['content'] != null) {
          assistantMessage = jsonResponse['message']['content'] as String;
          print('$_debugTag Parsed response using Ollama format');
        }
        // Fall back to OpenAI format (choices[0].message.content)
        else if (jsonResponse['choices'] != null && jsonResponse['choices'].isNotEmpty) {
          assistantMessage = jsonResponse['choices'][0]['message']['content'] as String;
          print('$_debugTag Parsed response using OpenAI format');
        }
        else {
          throw Exception('Unable to parse response - unexpected format: ${response.body}');
        }
        
        print('$_debugTag Successfully extracted response: $assistantMessage');
        return assistantMessage;
      } else {
        final errorMsg = 'Failed to get response from LLM. '
          'Status: ${response.statusCode}, '
          'Body: ${response.body}';
        print('$_debugTag ERROR: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('$_debugTag EXCEPTION: Error communicating with LLM: $e');
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
      print('$_debugTag Preparing advanced request to: ${_config.url}');
      print('$_debugTag Using model: ${_config.model}');
      print('$_debugTag Temperature: $temperature');
      if (maxTokens != null) print('$_debugTag Max tokens: $maxTokens');
      
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

      print('$_debugTag Request body:');
      print(jsonEncode(requestBody));

      final response = await http.post(
        Uri.parse(_config.url),
        headers: {
          'Content-Type': 'application/json',
          if (_config.authorization.isNotEmpty)
            'Authorization': 'Bearer ${_config.authorization}',
        },
        body: jsonEncode(requestBody),
      );

      print('$_debugTag Response status code: ${response.statusCode}');
      print('$_debugTag Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Handle both OpenAI and Ollama API formats
        String assistantMessage;
        
        // Try Ollama format first (message.content)
        if (jsonResponse['message'] != null && jsonResponse['message']['content'] != null) {
          assistantMessage = jsonResponse['message']['content'] as String;
          print('$_debugTag Parsed response using Ollama format');
        }
        // Fall back to OpenAI format (choices[0].message.content)
        else if (jsonResponse['choices'] != null && jsonResponse['choices'].isNotEmpty) {
          assistantMessage = jsonResponse['choices'][0]['message']['content'] as String;
          print('$_debugTag Parsed response using OpenAI format');
        }
        else {
          throw Exception('Unable to parse response - unexpected format: ${response.body}');
        }
        
        print('$_debugTag Successfully extracted response: $assistantMessage');
        return assistantMessage;
      } else {
        final errorMsg = 'Failed to get response from LLM. '
          'Status: ${response.statusCode}, '
          'Body: ${response.body}';
        print('$_debugTag ERROR: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('$_debugTag EXCEPTION: Error communicating with LLM: $e');
      throw Exception('Error communicating with LLM: $e');
    }
  }

  /// Tests the connection to the LLM API with a simple request
  /// Useful for verifying settings are correct
  /// 
  /// Returns true if connection is successful, false otherwise
  Future<bool> testConnection() async {
    try {
      print('$_debugTag Testing connection to: ${_config.url}');
      print('$_debugTag Using model: ${_config.model}');
      
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
        onTimeout: () {
          print('$_debugTag ERROR: Connection timeout after 10 seconds');
          throw Exception('Request timeout');
        },
      );

      print('$_debugTag Connection test response status: ${response.statusCode}');
      print('$_debugTag Connection test response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('$_debugTag Connection test SUCCESSFUL');
        return true;
      } else {
        print('$_debugTag Connection test FAILED with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('$_debugTag Connection test EXCEPTION: $e');
      return false;
    }
  }
}
