import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioRecordingService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  // Expose audioRecorder for chunked recording
  AudioRecorder get recorder => _audioRecorder;

  Future<bool> requestPermission() async {
    try {
      print('🔊 Starting permission request...');
      
      // First check if we already have permission via record package
      final hasPermission = await _audioRecorder.hasPermission();
      print('📱 Record package hasPermission: $hasPermission');
      
      if (hasPermission) {
        print('✅ Microphone permission already granted');
        return true;
      }
      
      // Request via permission_handler (this should trigger iOS popup)
      print('📞 Requesting permission via permission_handler...');
      final status = await Permission.microphone.request();
      print('📞 Permission request result: $status');
      
      // Check again with record package after request
      final recordHasPermission = await _audioRecorder.hasPermission();
      print('📱 Record package hasPermission after request: $recordHasPermission');
      
      final finalStatus = status.isGranted || recordHasPermission;
      print('✅ Final permission status: $finalStatus');
      
      return finalStatus;
    } catch (e, stackTrace) {
      print('❌ Error requesting microphone permission: $e');
      print('Stack trace: $stackTrace');
      
      // Fallback: try record package's permission
      try {
        final hasPermission = await _audioRecorder.hasPermission();
        print('🔄 Fallback: Record package permission: $hasPermission');
        return hasPermission;
      } catch (e2) {
        print('❌ Fallback also failed: $e2');
        return false;
      }
    }
  }

  Future<bool> hasPermission() async {
    try {
      // Check both permission_handler and record package
      final status = await Permission.microphone.status;
      final recordHasPermission = await _audioRecorder.hasPermission();
      print('Permission status - permission_handler: $status, record package: $recordHasPermission');
      return status.isGranted || recordHasPermission;
    } catch (e) {
      print('Error checking microphone permission: $e');
      // Fallback to record package
      try {
        return await _audioRecorder.hasPermission();
      } catch (e2) {
        return false;
      }
    }
  }

  Future<bool> shouldShowRequestRationale() async {
    try {
      final status = await Permission.microphone.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      return false;
    }
  }

  Future<String?> startRecording() async {
    try {
      print('🎙️ Starting recording...');
      
      // Double-check permission before starting
      final hasPermission = await _audioRecorder.hasPermission();
      print('📱 Record package permission check: $hasPermission');
      
      if (!hasPermission) {
        print('❌ Microphone permission not granted');
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );
      
      return filePath;
    } catch (e) {
      print('Error starting recording: $e');
      return null;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      return path;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _audioRecorder.stop();
      // Delete the temporary file if needed
    } catch (e) {
      print('Error canceling recording: $e');
    }
  }

  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  void dispose() {
    _audioRecorder.dispose();
  }

  Future<void> deleteRecordingFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting recording file: $e');
    }
  }
}
