import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';

class ImageCompressorScreen extends StatefulWidget {
  const ImageCompressorScreen({super.key});

  @override
  _ImageCompressorScreenState createState() => _ImageCompressorScreenState();
}

class _ImageCompressorScreenState extends State<ImageCompressorScreen> {
  final ImageCompressor _imageCompressor = ImageCompressor();

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageCompressor.originalImage = File(pickedFile.path);
      });
      _imageCompressor.compressImage(updateUI);
    }
  }

  void updateUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(68, 158, 158, 158),
      appBar: AppBar(title: const Text('Image Compressor')),
      body: SingleChildScrollView(
        
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Row: Original Image + Sliders
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original Image Section (Left Side)
                  Expanded(
                    child: Column(
                      children: [
                        if (_imageCompressor.originalImage != null) ...[
                          const Text("Original Image"),
                          Image.file(_imageCompressor.originalImage!, height: 200),
                          Text("Size: ${_imageCompressor.getFileSize(_imageCompressor.originalImage!)} KB"),
                          const SizedBox(height: 20),
                      
                          
                        ],
                        ElevatedButton(onPressed: _pickImage, child: const Text('Choose Image')),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 20),
          
                  // Compression Controls (Right Side)
                  Expanded(
                    child: Column(
                      children: [
                        const Text("Compression Level"),
                        Slider(
                          value: _imageCompressor.quality.toDouble(),
                          min: 10,
                          max: 100,
                          divisions: 9,
                          label: "${_imageCompressor.quality}%",
                          onChanged: (value) {
                            setState(() {
                              _imageCompressor.quality = value.toInt();
                              _imageCompressor.compressImage(updateUI);
                            });
                          },
                        ),
                        const Text("Resize Width"),
                        Slider(
                          value: _imageCompressor.targetWidth.toDouble(),
                          min: 100,
                          max: 2000,
                          
                          divisions: 19,
                          label: "${_imageCompressor.targetWidth}px",
                          onChanged: (value) {
                            setState(() {
                              _imageCompressor.targetWidth = value.toInt();
                              _imageCompressor.compressImage(updateUI);
                            });
                          },
                        ),
                        const Text("Resize Height"),
                        Slider(
                          value: _imageCompressor.targetHeight.toDouble(),
                          min: 100,
                          max: 2000,
                          divisions: 19,
                          label: "${_imageCompressor.targetHeight}px",
                          onChanged: (value) {
                            setState(() {
                              _imageCompressor.targetHeight = value.toInt();
                              _imageCompressor.compressImage(updateUI);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          
              const SizedBox(height: 20),
          
              // Compressed Image Section (Below the Row)
              if (_imageCompressor.compressedImage != null) ...[
                const Text("Compressed Image"),
                Image.file(
                  _imageCompressor.compressedImage!,
                  width: _imageCompressor.targetWidth.toDouble(),
                  height: _imageCompressor.targetHeight.toDouble(),
                  fit: BoxFit.cover,
                ),
                Text("Size: ${_imageCompressor.getFileSize(_imageCompressor.compressedImage!)} KB"),
                const SizedBox(height: 10),
                
                // Download & Share Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _imageCompressor.downloadImage(context),
                      child: const Text('Download Image'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _imageCompressor.shareImage,
                      child: const Text('Share Image'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Image Compressor Class
class ImageCompressor {
  File? originalImage;
  File? compressedImage;
  int quality = 70;
  int targetWidth = 800;
  int targetHeight = 800;

  Future<void> compressImage(VoidCallback updateUI) async {
  if (originalImage == null) return;

  final bytes = await originalImage!.readAsBytes();
  img.Image? image = img.decodeImage(bytes);

  if (image == null) return;

  // Calculate aspect ratio-preserving dimensions
  double aspectRatio = image.width / image.height;
  int newWidth, newHeight;

  if (image.width > image.height) {
    newWidth = targetWidth;
    newHeight = (targetWidth / aspectRatio).round();
  } else {
    newHeight = targetHeight;
    newWidth = (targetHeight * aspectRatio).round();
  }

  // Resize while maintaining aspect ratio
  image = img.copyResize(image, width: newWidth, height: newHeight);

  // Compress and save
  final compressedBytes = img.encodeJpg(image, quality: quality);
  final dir = await getTemporaryDirectory();
  final targetPath = '${dir.path}/compressed.jpg';

  File(targetPath).writeAsBytesSync(compressedBytes);

  // Update compressedImage and refresh UI
  compressedImage = File(targetPath);
  updateUI();
}


  void shareImage() {
    if (compressedImage != null) {
      Share.shareXFiles([XFile(compressedImage!.path)], text: "Here's my compressed image!");
    }
  }

Future<void> downloadImage(BuildContext context) async {
  if (compressedImage != null) {
    // Show format selection dialog
    String? selectedExtension = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select File Format"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("JPG"),
                onTap: () => Navigator.pop(context, "jpg"),
              ),
              ListTile(
                title: Text("PNG"),
                onTap: () => Navigator.pop(context, "png"),
              ),
              ListTile(
                title: Text("SVG"),
                onTap: () => Navigator.pop(context, "svg"),
              ),
            ],
          ),
        );
      },
    );

    if (selectedExtension != null) {
      // Open save file dialog
      String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Image As',
        fileName: 'compressed_image_${DateTime.now().millisecondsSinceEpoch}.$selectedExtension',
        type: FileType.custom,
        allowedExtensions: [selectedExtension],
      );

      if (filePath != null) {
        await compressedImage!.copy(filePath);

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image saved to: $filePath ✅")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download canceled ❌")),
        );
      }
    }
  }
}


  int getFileSize(File file) {
    return file.existsSync() ? file.lengthSync() ~/ 1024 : 0; // KB
  }
}
