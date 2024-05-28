import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class PdfToTextScreen extends StatefulWidget {
  @override
  _PdfToTextScreenState createState() => _PdfToTextScreenState();
}

class _PdfToTextScreenState extends State<PdfToTextScreen> {
  String _selectedPdfFileName = '';
  File? _selectedPdfFile;

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _selectedPdfFileName = file.path.split('/').last;
        _selectedPdfFile = file;
      });
    }
  }

  Future<void> _convertPdfToImages() async {
    if (_selectedPdfFile == null) return;

    try {
      // Creating a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://pdf-converter-api.p.rapidapi.com/PdfToImage'),
      );

      // Adding the PDF file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'pdfFile',
          _selectedPdfFile!.path,
        ),
      );

      // Adding query parameters
      request.fields.addAll({
        'imgFormat': 'tifflzw',
        'startPage': '0',
        'endPage': '0',
      });

      // Adding headers
      request.headers.addAll({
        'X-RapidAPI-Key': '645228621bmshf0ae16afd17e9e2p140f91jsnf029457f37b4',
        'X-RapidAPI-Host': 'pdf-converter-api.p.rapidapi.com',
      });

      // Sending the request and getting response
      var response = await request.send();

      // Handling the response
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseBody);
        print(decodedResponse);
      } else {
        print('Failed to convert PDF to images: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error converting PDF to images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF to Images Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickPdfFile,
              child: Text('Upload PDF'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertPdfToImages,
              child: Text('Convert to Images'),
            ),
            SizedBox(height: 20),
            _selectedPdfFileName.isNotEmpty
                ? Text(
              'Selected PDF: $_selectedPdfFileName',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PdfToTextScreen(),
  ));
}
