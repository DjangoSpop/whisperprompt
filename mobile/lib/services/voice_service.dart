import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  bool get isRecording => _isRecording;
  Duration get recordingDuration {
    if (_recordingStartTime == null) return Duration.zero;
    return DateTime.now().difference(_recordingStartTime!);
  }

  Future<bool> checkPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;

    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  Future<String?> startRecording() async {
    if (_isRecording) {
      throw Exception('Already recording');
    }

    final hasPermission = await checkPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    try {
      // Generate file path
      final directory = await getTemporaryDirectory();
      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = '${directory.path}/$fileName';

      // Start recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      _recordingStartTime = DateTime.now();

      return _currentRecordingPath;
    } catch (e) {
      _isRecording = false;
      _recordingStartTime = null;
      _currentRecordingPath = null;
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return null;
    }

    try {
      final path = await _recorder.stop();
      _isRecording = false;

      final recordingPath = _currentRecordingPath;
      _currentRecordingPath = null;
      _recordingStartTime = null;

      return path ?? recordingPath;
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;
      _recordingStartTime = null;
      rethrow;
    }
  }

  Future<void> cancelRecording() async {
    if (!_isRecording) return;

    try {
      await _recorder.stop();
      _isRecording = false;

      // Delete the file
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      _currentRecordingPath = null;
      _recordingStartTime = null;
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;
      _recordingStartTime = null;
      rethrow;
    }
  }

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  void dispose() {
    _recorder.dispose();
  }
}
