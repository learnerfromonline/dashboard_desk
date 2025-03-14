import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? fileController;
  VideoPlayerController? urlController;
  ChewieController? chewieController;
  TextEditingController urlTextController = TextEditingController();
  bool _isUrlLoaded = false;
  bool _loading = false;

  Future<void> _initializeFileVideoController(File? file) async {
    if (file != null) {
      fileController = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {
            
          });
          _initializeChewieController(fileController);
          fileController?.play();
        }).catchError((e) {
          log("File controller.initialize() error occurs: $e");
        });
    }
  }

  Future<void> _initializeUrlVideoController(String url) async {
    if (url.isNotEmpty) {
      urlController = VideoPlayerController.network(url)
        ..initialize().then((_) {
          setState(() {
            
          });
          _initializeChewieController(urlController);
          urlController?.play();
        }).catchError((e) {
          log("URL controller.initialize() error occurs: $e");
        });
    }
  }

  void _initializeChewieController(VideoPlayerController? controller) {
    chewieController?.dispose();
    chewieController = ChewieController(
      videoPlayerController: controller!,
      aspectRatio: controller.value.aspectRatio,
      autoPlay: true,
      looping: true,
      showControls: true,
    );
  }

  Future<void> _pickVideoFile() async {
    setState(() {
      _loading = true;
    });

    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _initializeFileVideoController(File(pickedFile.path));
        _isUrlLoaded = true;
      }
      _loading = false;
    });
  }

  void _showUrlDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter m3u8 URL'),
          content: TextField(
            controller: urlTextController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'm3u8 URL',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeUrlVideoController(urlTextController.text);
              },
              child: Text('Load'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadVideo(String url) async {
    final pickedDirectory = await FilePicker.platform.getDirectoryPath();

    if (pickedDirectory != null) {
      final response = await HttpClient().getUrl(Uri.parse(url));
      final bytes = await consolidateHttpClientResponseBytes(await response.close());
      final file = File('$pickedDirectory/downloaded_video.mp3');
      await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video downloaded to ${file.path}')),
      );
    }
  }

  @override
  void dispose() {
    fileController?.dispose();
    urlController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(82, 255, 193, 7),
        title: const Text('Enjoy The Experience',textAlign: TextAlign.center,style: TextStyle(color: Colors.blue)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onDoubleTap: () {
                setState(() {
                  chewieController?.toggleFullScreen();
                });
              },
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: const Color.fromARGB(105, 75, 227, 67),width: 12),color: Colors.black,borderRadius: BorderRadius.circular(30)),
                
                margin: EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height / 2,
                child: chewieController != null && chewieController!.videoPlayerController.value.isInitialized
                    ? Chewie(
                        controller: chewieController!,
                      ).animate(
                        // onPlay: (controller) => controller.repeat(reverse: true),
                      ).slide(duration: 500.ms)
                    : Center(child: CircularProgressIndicator()),
              ).animate(
                // onPlay: (controller) => controller.repeat(reverse: true),
              ).scale(duration: 1500.ms),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickVideoFile,
                    icon: Icon(Icons.video_library),
                    label: Text('Pick Video File',style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  ).slide(duration: 500.ms),
                  SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    onPressed: _showUrlDialog,
                    icon: Icon(Icons.link),
                    label: Text('Load Video from URL',style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  ).slide(duration: 500.ms),
                    SizedBox(height: 16.0),
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


