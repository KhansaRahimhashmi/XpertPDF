import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TextFromImageScreen(),
  ));
}

class TextFromImageScreen extends StatefulWidget {
  @override
  _TextFromImageScreenState createState() => _TextFromImageScreenState();
}

class _TextFromImageScreenState extends State<TextFromImageScreen> {
  File? _image;
  String _extractedText = '';
  bool _isLoading = false;
  bool _errorShown = false;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _extractedText = '';
          _errorShown = false;
        });
        await _extractTextFromImage(_image!);
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _extractTextFromImage(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText? recognizedText = await textRecognizer.processImage(inputImage);

      if (recognizedText != null) {
        String extractedText = recognizedText.text;

        setState(() {
          _extractedText = extractedText;
        });

        if (extractedText.isNotEmpty) {
          await _createPdf(extractedText);
        } else {
          _showError('No text found in the image.');
        }
      } else {
        _showError('No text found in the image.');
      }

      textRecognizer.close();
    } catch (e) {
      if (!_errorShown) {
        _errorShown = true;
        _showError('Failed to extract text: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createPdf(String text) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Text(text),
          ),
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/extracted_text.pdf");
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved at ${file.path}')),
      );
    } catch (e) {
      _showError('Failed to create PDF: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text from Images'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _image != null
                ? Image.file(_image!)
                : Container(),
            SizedBox(height: 20),
            Text(
              _extractedText.isNotEmpty
                  ? 'Extracted Text:\n$_extractedText'
                  : 'No text extracted yet.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
