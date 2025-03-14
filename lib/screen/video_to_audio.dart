import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class VideoToAudioScreen extends StatefulWidget {
  @override
  _VideoToAudioScreenState createState() => _VideoToAudioScreenState();
}

class _VideoToAudioScreenState extends State<VideoToAudioScreen> {
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  String? _videoPath;
  String? _outputPath;
  bool _isConverting = false;

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      setState(() {
        _videoPath = result.files.single.path;
        _outputPath = null;
      });
    }
  }

  Future<void> _convertToAudio() async {
    if (_videoPath == null) return;

    setState(() {
      _isConverting = true;
    });

    String outputDir = (await getTemporaryDirectory()).path;
    String outputFileName = path.basenameWithoutExtension(_videoPath!) + ".mp3";
    _outputPath = path.join(outputDir, outputFileName);

    int result = await _flutterFFmpeg.execute(
      '-i "$_videoPath" -vn -acodec libmp3lame "$_outputPath"'
    );

    setState(() {
      _isConverting = false;
    });

    if (result == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Conversion Successful: $_outputPath")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Conversion Failed")),
      );
    }
  }

  Future<void> _saveAudioFile() async {
    if (_outputPath == null) return;

    String? savePath = await FilePicker.platform.saveFile(
      dialogTitle: "Save Audio File",
      fileName: path.basename(_outputPath!),
    );

    if (savePath != null) {
      File(_outputPath!).copy(savePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File saved to: $savePath")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video to Audio Converter")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text("Select Video"),
            ),
            if (_videoPath != null) ...[
              SizedBox(height: 10),
              Text("Selected Video: ${path.basename(_videoPath!)}"),
              SizedBox(height: 10),
              _isConverting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _convertToAudio,
                      child: Text("Convert to Audio"),
                    ),
            ],
            if (_outputPath != null) ...[
              SizedBox(height: 10),
              Text("Output: $_outputPath"),
              ElevatedButton(
                onPressed: _saveAudioFile,
                child: Text("Save Audio"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
