import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class HtmlToPdfPage extends StatefulWidget {
  @override
  _HtmlToPdfPageState createState() => _HtmlToPdfPageState();
}

class _HtmlToPdfPageState extends State<HtmlToPdfPage> {
  TextEditingController _htmlController = TextEditingController();
  String _pdfPath = '';

  Future<void> convertHtmlToPdf() async {
    final String apiUrl = 'https://yakpdf.p.rapidapi.com/pdf';
    final String apiKey = '645228621bmshf0ae16afd17e9e2p140f91jsnf029457f37b4';

    final Map<String, dynamic> requestData = {
      'source': {
        'html': _htmlController.text,
      },
      'pdf': {
        'format': 'A4',
        'scale': 1,
        'printBackground': true,
      },
      'wait': {
        'for': 'navigation',
        'waitUntil': 'load',
        'timeout': 2500,
      },
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-RapidAPI-Key': apiKey,
          'X-RapidAPI-Host': 'yakpdf.p.rapidapi.com',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        Uint8List pdfBytes = response.bodyBytes;
        Directory? downloadsDir = await getExternalStorageDirectory();
        String downloadsPath = '${downloadsDir!.path}/Download';
        Directory(downloadsPath).createSync(recursive: true);
        String filePath = '$downloadsPath/converted.pdf';
        File file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        setState(() {
          _pdfPath = filePath;
        });
      } else {
        print('Failed to convert HTML to PDF: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> openPdf() async {
    if (_pdfPath.isNotEmpty) {
      final result = await OpenFile.open(_pdfPath);
      print(result.message);
    } else {
      print('No PDF path found');
    }
  }

  Future<void> testApiRequest() async {
    final String testUrl = 'https://jsonplaceholder.typicode.com/posts';

    try {
      final response = await http.get(Uri.parse(testUrl));

      if (response.statusCode == 200) {
        print('Test API Request Successful');
        print('Response: ${response.body}');
      } else {
        print('Test API Request Failed: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit & Save HTML'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Landing Page.html',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _htmlController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter HTML content here...',
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: convertHtmlToPdf,
              child: Text('Convert to PDF'),
            ),
            ElevatedButton(
              onPressed: testApiRequest,
              child: Text('Test API Request'),
            ),
            if (_pdfPath.isNotEmpty)
              Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'PDF Generated! Download here:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: openPdf,
                    child: Text(
                      'Open PDF',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
