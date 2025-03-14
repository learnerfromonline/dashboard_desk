import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Add this line for loading animation

class ImageToPdf extends StatefulWidget {
  @override
  _ImageToPdfState createState() => _ImageToPdfState();
}

class _ImageToPdfState extends State<ImageToPdf> {
  bool _isselect = false;
  File? _image;
  final picker = ImagePicker();
  bool _loading = false;

  Future<void> _pickImage() async {
    setState(() {
      _loading = true;
    });

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
      _loading = false;
      _isselect = true; 
    });
  }

  Future<void> _convertToPdf() async {
    if (_image == null) return;

    final pdf = pw.Document();
    final image = pw.MemoryImage(_image!.readAsBytesSync());
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(child: pw.Image(image));
    }));

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  Future<void> _savePdf() async {
    if (_image == null) return;

    final pdf = pw.Document();
    final image = pw.MemoryImage(_image!.readAsBytesSync());
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(child: pw.Image(image));
    }));

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF',
      fileName: 'example.pdf',
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsBytes(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF Saved: ${file.path}')),
      );
    }
  }

  Future<void> _sharePdf() async {
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    Share.shareXFiles([XFile(file.path)], text: 'Here is your PDF!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image to PDF'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _loading
                  ? SpinKitFadingCircle(color: Colors.indigoAccent, size: 50.0)
                  : _image == null
                      ? Text(
                          'No image selected.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        )
                      : Padding(

                        padding: const EdgeInsets.all(18.0),
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.indigoAccent, width: 2),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(10),
                            child: Image.file(_image!).animate(
                              // onPlay: (controller) => controller.repeat(count: 2),
                            ).scale(duration: 1000.ms),
                          ),
                      ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text(_isselect?"Want to convert Another":"Select Image",style: TextStyle(color: _isselect?Colors.white:Colors.black),),
                style: ElevatedButton.styleFrom(
                  backgroundColor:_isselect?Colors.black:Colors.white,
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              ).slide(duration: 500.ms),
              if (_image != null) ...[
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _convertToPdf,
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text('View PDF',style: TextStyle(color: Colors.black),),
                      
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        iconColor: Colors.black,
                        enabledMouseCursor: MouseCursor.uncontrolled,
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    ).slide(duration: 600.ms),
                    ElevatedButton.icon(
                      onPressed: _savePdf,
                      icon: Icon(Icons.save_alt),
                      label: Text('Save PDF',style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        iconColor: Colors.black,
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    ).slide(duration: 700.ms),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _sharePdf,
                  icon: Icon(Icons.share),
                  label: Text('Share PDF',style: TextStyle(color: Colors.black),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                        iconColor: Colors.black,
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ).animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                ).slide(duration: 800.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
