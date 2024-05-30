import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:open_file/open_file.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image to PDF Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageToPdfConverter(),
    );
  }
}

class ImageToPdfConverter extends StatefulWidget {
  @override
  _ImageToPdfConverterState createState() => _ImageToPdfConverterState();
}

class _ImageToPdfConverterState extends State<ImageToPdfConverter> {
  List<XFile> _imageFiles = [];

  Future<void> _pickImagesFromGallery() async {
    final pickedFiles = await ImagePicker().pickMultiImage(
      maxWidth: 1000, // Adjust this as needed
      maxHeight: 1000, // Adjust this as needed
    );
    setState(() {
      if (pickedFiles != null) {
        _imageFiles.addAll(pickedFiles);
      }
    });
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1000, // Adjust this as needed
      maxHeight: 1000, // Adjust this as needed
    );
    setState(() {
      if (pickedFile != null) {
        _imageFiles.add(pickedFile);
      }
    });
  }

  Future<void> _convertToPdf() async {
    if (_imageFiles.isNotEmpty) {
      final pdf = pdfLib.Document();
      for (final imageFile in _imageFiles) {
        final image = pdfLib.MemoryImage(File(imageFile.path).readAsBytesSync());
        pdf.addPage(pdfLib.Page(build: (pdfLib.Context context) {
          return pdfLib.Center(child: pdfLib.Image(image));
        }));
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        // Handle error - directory not found
        return;
      }

      final filePath = '${directory.path}/images_to_pdf.pdf';
      final output = await File(filePath).writeAsBytes(await pdf.save());
      OpenFile.open(output.path);
    } else {
      // Show a snackbar or alert dialog to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select images before converting to PDF'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick Images'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _pickImageFromCamera,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.pink, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                child: Text('Camera'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _pickImagesFromGallery,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.grey, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                child: Text('Gallery'),
              ),
            ],
          ),
          Expanded(
            child: _imageFiles.isEmpty
                ? Center(child: Text('No images selected'))
                : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Adjust the number of images per row
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _imageFiles.length,
              itemBuilder: (context, index) => Image.file(
                File(_imageFiles[index].path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _convertToPdf,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.pink, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              child: Text('Convert into PDF'),
            ),
          ),
        ],
      ),
    );
  }
}