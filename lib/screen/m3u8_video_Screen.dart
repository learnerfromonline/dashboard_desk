import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';

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

  GlobalKey playerScreenshotKey = GlobalKey(); // Key for Video Player Screenshot

  Future<void> _initializeFileVideoController(File? file) async {
    if (file != null) {
      fileController = VideoPlayerController.file(file)
        ..initialize().then((_) {
          setState(() {});
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
          setState(() {});
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
ScreenshotController screenshotController = ScreenshotController();
  // Future<void> _takeScreenshot() async {
  //   try {
  //     // Capture only the video player widget
  //     RenderRepaintBoundary boundary =
  //         playerScreenshotKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
  //     ui.Image image = await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
  //     ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //     Uint8List pngBytes = byteData!.buffer.asUint8List();

  //     // Let user select the folder to save the screenshot
  //     String? directoryPath = await FilePicker.platform.getDirectoryPath();
  //     if (directoryPath != null) {
  //       String defaultFileName = 'video_player_screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
  //       File file = File('$directoryPath/$defaultFileName');
  //       await file.writeAsBytes(pngBytes);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Screenshot saved to $file")),
  //       );
  //     }
  //   } catch (e) {
  //     log("Screenshot error: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Failed to take screenshot.")),
  //     );
  //   }
  // }
 Future<void> _takeScreenshot() async {
    Uint8List? image = await screenshotController.capture();
    if (image != null) {
      String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Screenshot',
        fileName: 'screenshot.png',
        type: FileType.image,
        allowedExtensions: ['png'],
      );

      if (filePath != null) {
        if (!filePath.toLowerCase().endsWith('.png')) {
          filePath += '.png';
        }

        final file = File(filePath);
        await file.writeAsBytes(image);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Screenshot saved to $filePath')),
        );
      }
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
        title: const Text('Enjoy The Experience', textAlign: TextAlign.center, style: TextStyle(color: Colors.blue)),
        actions: [
          IconButton(
            onPressed: _takeScreenshot,
            icon: Icon(Icons.camera),
            tooltip: "Take Screenshot",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Wrap only the video player with RepaintBoundary
            RepaintBoundary(
              key: playerScreenshotKey, // Key for capturing video player screenshot
              child: GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    chewieController?.toggleFullScreen();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color.fromARGB(105, 75, 227, 67), width: 12),
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  margin: EdgeInsets.all(20),
                  height: MediaQuery.of(context).size.height / 2,
                  child: chewieController != null && chewieController!.videoPlayerController.value.isInitialized
                      ? Screenshot(
                        controller: screenshotController,
                        
                        child: Chewie(
                            controller: chewieController!,
                          ),
                      )
                      : Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final pickedFile =
                          await ImagePicker().pickVideo(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        _initializeFileVideoController(File(pickedFile.path));
                      }
                    },
                    icon: Icon(Icons.video_library),
                    label: Text('Pick Video File', style: TextStyle(color: Colors.black)),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showUrlDialog();
                    },
                    icon: Icon(Icons.link),
                    label: Text('Load Video from URL', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
}
