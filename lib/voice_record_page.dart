import 'package:flutter/material.dart';
import 'package:record/record.dart'; // Audio recording package
import 'dart:io'; // File-related operations
import 'package:path_provider/path_provider.dart'; // To get temporary storage paths
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'user_manager.dart'; // Custom user management
import 'package:just_audio/just_audio.dart';

class VoiceRecordPage extends StatefulWidget {
  const VoiceRecordPage({super.key});

  @override
  _VoiceRecordPageState createState() => _VoiceRecordPageState();
}

class _VoiceRecordPageState extends State<VoiceRecordPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _filePath; // Recorded file path
  String _fileName = ''; // File name entered by the user
  final TextEditingController _fileNameController = TextEditingController(); // File name input controller
  double _currentPosition = 0;
  double _totalDuration = 0;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _recorder.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _recorder.stop();
      setState(() {
        _isRecording = false;
      });
      print('Recording stopped. File saved at $_filePath');
    } else {
      // Request microphone permission
      final bool isPermissionGranted = await _recorder.hasPermission();
      if (!isPermissionGranted) return;

      // Set the path where the file will be saved
      final directory = await getApplicationDocumentsDirectory();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      _filePath = '${directory.path}/${_fileName.isNotEmpty ? _fileName : "recording_$timestamp"}.m4a';

      // Create folder if it doesn't exist
      final folder = Directory(directory.path);
      if (!folder.existsSync()) {
        await folder.create(recursive: true);
      }

      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      );

      // Start recording
      print('Recording started: $_filePath');
      await _recorder.start(config, path: _filePath!);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _playRecording() async {
    if (_filePath != null) {
      await _audioPlayer.setFilePath(_filePath!);
      _totalDuration = _audioPlayer.duration?.inSeconds.toDouble() ?? 0;
      _audioPlayer.play();

      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _currentPosition = position.inSeconds.toDouble();
        });
      });
    }
  }

  Future<void> _uploadFile() async {
    print('Uploading file...');
    UserManager userManager = UserManager();

    if (_filePath != null && _fileName.isNotEmpty) {
      final url = Uri.parse('http://172.10.7.22:3000/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['file_name'] = _fileName
        ..fields['user_id'] = userManager.getUserId().toString()
        ..files.add(await http.MultipartFile.fromPath(
          'files[]', // Expected field name on the server
          _filePath!, // Path of the recorded file
          contentType: MediaType('audio', 'm4a'),
        ));

      final response = await request.send();
      if (response.statusCode == 200) {
        print('Upload successful');
      } else {
        print('Upload failed with status: ${response.statusCode}');
      }
    } else {
      print('File path or file name is missing.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 100,
              color: _isRecording ? Colors.red : const Color(0xFF8928EA),
            ),
            if (_isRecording)
              TextButton(
                onPressed: _toggleRecording,
                child: const Text(
                  'Stop',
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ),
              )
            else
              TextButton(
                onPressed: _toggleRecording,
                child: const Text(
                  'Record',
                  style: TextStyle(fontSize: 20, color: Color(0xFF8928EA)),
                ),
              ),
            const SizedBox(height: 20),
            Slider(
              value: _currentPosition,
              max: _totalDuration,
              onChanged: (value) {
                setState(() {
                  _currentPosition = value;
                });
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: !_isRecording ? _playRecording : null,
                  child: const Text('Play'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: !_isRecording ? _uploadFile : null,
                  child: const Text('Upload'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _fileNameController,
              decoration: const InputDecoration(
                labelText: 'Enter file name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _fileName = value.trim();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
