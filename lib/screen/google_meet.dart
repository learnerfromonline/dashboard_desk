import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:screenshot/screenshot.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleMeetScreen extends StatefulWidget {
  @override
  _GoogleMeetScreenState createState() => _GoogleMeetScreenState();
}

class _GoogleMeetScreenState extends State<GoogleMeetScreen> {
  final WebviewController _controller = WebviewController();
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = true;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _initWebView();
    _requestPermissions();
  }

  Future<void> _initWebView() async {
    await _controller.initialize();
    setState(() => _isLoading = false);
    _controller.loadUrl('about:blank');
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.camera.request();
  }

  void _loadMeet() {
    String meetUrl = _urlController.text.trim();
    if (meetUrl.isNotEmpty) {
      _controller.loadUrl(meetUrl);
      _controller.loadingState.listen((event) {
        if (event == LoadingState.navigationCompleted) {
          _removeMeetElements();
        }
      });
    }
  }

  Future<void> _removeMeetElements() async {
    String jsCode = '''
    var chatPanel = document.querySelector('[aria-label="Show everyone"]');
    if (chatPanel) {
      chatPanel.style.display = 'none';
    }

    var participantsList = document.querySelector('[aria-label="People"]');
    if (participantsList) {
      participantsList.style.display = 'none';
    }

    var screenShareButton = document.querySelector('[aria-label="Present now"]');
    if (screenShareButton) {
      screenShareButton.style.display = 'none';
    }

    var controlButtons = document.querySelectorAll('[jscontroller="tzwank"]');
    controlButtons.forEach(function(button) {
        if (button.ariaLabel != "Leave call"){
            button.style.display = 'none';
        }
    });

    // Hide Microphone and Camera buttons
    var micButton = document.querySelector('[aria-label="Turn on microphone"]');
    if (micButton) {
      micButton.style.display = 'none';
    }

    var cameraButton = document.querySelector('[aria-label="Turn on camera"]');
    if (cameraButton) {
      cameraButton.style.display = 'none';
    }
  ''';

    await _controller.executeScript(jsCode);
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.black26,
        centerTitle: true,
        title: Text('Online Meet Player'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera),
            onPressed: _takeScreenshot,
          ),
          
        ],
      ),
      body: Column(
        
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: 'Enter  Meet URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _loadMeet,
                  child: Text('Join'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Screenshot(
                    controller: screenshotController,
                    child: Webview(_controller),
                  ),
          ),
        ],
      ),
    );
  }
}
