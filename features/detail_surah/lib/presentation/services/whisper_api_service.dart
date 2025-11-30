import 'dart:io';
import 'package:dio/dio.dart' show Dio, Options, FormData, MultipartFile;
import 'package:config/api_config.dart' show ApiConfig;

class WhisperApiService {
  final Dio _dio = Dio();
  
  // OpenAI API Key for Whisper transcription
  // Get from environment variable or api_config.dart
  static String get openAiApiKey {
    // Try environment variable first
    const envKey = String.fromEnvironment('OPENAI_API_KEY');
    if (envKey.isNotEmpty) {
      return envKey;
    }
    // Fallback to api_config (which should be gitignored)
    try {
      // Import api_config if it exists
      // Note: This will fail if api_config.dart doesn't exist, which is expected
      // The user should create it with their API key
      return ApiConfig.openAiApiKey;
    } catch (e) {
      throw Exception('OpenAI API key not found. Please set OPENAI_API_KEY environment variable or create lib/config/api_config.dart with your API key');
    }
  }
  static const String openAiApiUrl = 'https://api.openai.com/v1/audio/transcriptions';

  Future<String?> transcribeAudio(String audioFilePath, {bool isRealtime = false}) async {
    try {
      final file = File(audioFilePath);
      if (!await file.exists()) {
        if (!isRealtime) {
          print('Audio file does not exist: $audioFilePath');
        }
        return null;
      }

      // Check file size - if too small, skip (file might still be writing)
      final fileSize = await file.length();
      if (fileSize < 1000) { // Less than 1KB, probably incomplete
        if (!isRealtime) {
          print('Audio file too small: $fileSize bytes');
        }
        return null;
      }
      
      if (isRealtime) {
        print('🌐 Sending chunk to Whisper API (${fileSize} bytes)...');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFilePath,
          filename: 'recording.m4a',
        ),
        'model': 'whisper-1',
        'language': 'ar', // Arabic language
      });

      final response = await _dio.post(
        openAiApiUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $openAiApiKey',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final transcription = response.data['text'] as String?;
        final result = transcription?.trim();
        if (isRealtime && result != null) {
          print('✅ Whisper API response: "$result"');
        }
        return result;
      } else {
        if (!isRealtime) {
          print('Whisper API error: ${response.statusCode} - ${response.data}');
        } else {
          print('⚠️ Whisper API error: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      // Handle errors during real-time transcription
      if (isRealtime) {
        // Check error type
        final errorStr = e.toString();
        if (errorStr.contains('400') || errorStr.contains('Http status error [400]')) {
          // 400: Bad request - file might be invalid or too small
          print('⚠️ Whisper API 400 error: Invalid file format or too small');
          return null;
        } else if (errorStr.contains('429') || errorStr.contains('Http status error [429]')) {
          // 429: Rate limit - too many requests
          print('⚠️ Whisper API 429 error: Rate limit exceeded, slowing down...');
          return null;
        } else if (errorStr.contains('520') || errorStr.contains('Http status error [520]')) {
          // 520: Server error - temporary issue
          print('⚠️ Whisper API 520 error: Server error, will retry...');
          return null;
        } else {
          print('❌ Whisper API error: $e');
        }
      } else {
        print('Error transcribing audio: $e');
      }
      return null;
    }
  }
}
