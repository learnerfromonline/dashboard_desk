import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;



class ImageCompressorScreen extends StatefulWidget {
  @override
  _ImageCompressorScreenState createState() => _ImageCompressorScreenState();
}

class _ImageCompressorScreenState extends State<ImageCompressorScreen> {
  File? _originalImage;
  Uint8List? _compressedImageBytes;
  int _compressionQuality = 80;
  int? _newWidth;
  int? _newHeight;
  String _originalImageInfo = '';
  String _compressedImageInfo = '';
  bool _isCompressing = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _originalImage = File(pickedFile.path);
        _compressedImageBytes = null;
        _newWidth = null;
        _newHeight = null;
      });
      _updateOriginalImageInfo();
    }
  }

Future<void> _compressImage() async {
  if (_originalImage == null) return;

  setState(() {
    _isCompressing = true;
  });

  try {
    final image = img.decodeImage(await _originalImage!.readAsBytes());
    if (image == null) {
      throw Exception('Failed to decode image.');
    }

    int width = _newWidth ?? image.width;
    int height = _newHeight ?? image.height;

    final resizedImage = img.copyResize(image, width: width, height: height);
    final compressedBytes = img.encodeJpg(resizedImage, quality: _compressionQuality);

    setState(() {
      _compressedImageBytes = Uint8List.fromList(compressedBytes);
    });
    _updateCompressedImageInfo();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error compressing image: $e')),
    );
  } finally {
    setState(() {
      _isCompressing = false;
    });
  }
}

 
Future<void> _downloadImage() async {
  if (_compressedImageBytes == null) return;

  try {
    String? selectedFormat = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Image Format'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'jpg');
              },
              child: const Text('JPG'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'png');
              },
              child: const Text('PNG'),
            ),
          ],
        );
      },
    );

    if (selectedFormat == null) return; // User canceled format selection.

    String fileExtension = selectedFormat.toLowerCase();
    String fileName = 'compressed_image_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    String? savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Compressed Image',
      allowedExtensions: [fileExtension],
      type: FileType.custom,
      fileName: fileName,
    );

    if (savePath == null) return; // User canceled save.

    if (!savePath.toLowerCase().endsWith('.$fileExtension')) {
      savePath += '.$fileExtension'; // Append extension if missing
    }

    File file = File(savePath);

    if (selectedFormat == 'jpg') {
      await file.writeAsBytes(_compressedImageBytes!);
    } else if (selectedFormat == 'png') {
      final decodedImage = img.decodeImage(_compressedImageBytes!);
      if (decodedImage == null) {
        throw Exception('Failed to decode image.');
      }
      final pngBytes = img.encodePng(decodedImage);
      await file.writeAsBytes(pngBytes);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image downloaded to $savePath')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error downloading image: $e')),
    );
  }
}


  Future<void> _shareImage() async {
    if (_compressedImageBytes == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = path.join(tempDir.path, 'compressed_image.jpg');
      final file = File(filePath);
      await file.writeAsBytes(_compressedImageBytes!);

      await Share.shareXFiles([XFile(filePath)], text: 'Compressed Image');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing image: $e')),
      );
    }
  }

  void _updateOriginalImageInfo() async {
    if (_originalImage == null) return;
    final file = _originalImage!;
    final sizeInBytes = await file.length();
    final decodedImage = img.decodeImage(await file.readAsBytes());
    final sizeInKB = sizeInBytes / 1024;
    final name = path.basename(file.path);
    setState(() {
      _originalImageInfo = 'Name: $name\nSize: ${sizeInKB.toStringAsFixed(2)} KB\nWidth: ${decodedImage?.width ?? 0} px\nHeight: ${decodedImage?.height ?? 0} px';
    });
  }

  void _updateCompressedImageInfo() async {
    if (_compressedImageBytes == null) return;
    final sizeInBytes = _compressedImageBytes!.length;
    final decodedImage = img.decodeImage(_compressedImageBytes!);
    final sizeInKB = sizeInBytes / 1024;
    setState(() {
      _compressedImageInfo = 'Size: ${sizeInKB.toStringAsFixed(2)} KB\nWidth: ${decodedImage?.width ?? 0} px\nHeight: ${decodedImage?.height ?? 0} px';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Compressor')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(onPressed: _pickImage, child: Text('Select Image')),
              SizedBox(height: 16),
              if (_originalImage != null) ...[
                Image.file(_originalImage!),
                SizedBox(height: 8),
                Text(_originalImageInfo),
                SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Width (px)'),
                  onChanged: (value) => _newWidth = int.tryParse(value),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Height (px)'),
                  onChanged: (value) => _newHeight = int.tryParse(value),
                ),
                Slider(
                  value: _compressionQuality.toDouble(),
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: 'Quality: $_compressionQuality',
                  onChanged: (value) {
                    setState(() {
                      _compressionQuality = value.round();
                    });
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isCompressing ? null : _compressImage,
                  child: _isCompressing ? CircularProgressIndicator() : Text('Compress Image'),
                ),
                SizedBox(height: 16),
                if (_compressedImageBytes != null) ...[
                  Image.memory(_compressedImageBytes!),
                  SizedBox(height:8),
                  Text(_compressedImageInfo),
                  SizedBox(height: 16),
                  ElevatedButton(onPressed: _downloadImage, child: Text('Download')),
                  SizedBox(height: 20,),
                  ElevatedButton(onPressed: _shareImage, child: Text('Share')),
                ],
              ]
              else ...[
                  Image.asset("assets/choose.gif")
              ],
            ],
          ),
        ),
      ),
    );
  }
}