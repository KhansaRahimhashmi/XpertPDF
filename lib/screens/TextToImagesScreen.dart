import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class TextToImagesScreen extends StatefulWidget {
  @override
  _TextToImagesScreenState createState() => _TextToImagesScreenState();
}

class _TextToImagesScreenState extends State<TextToImagesScreen> {
  String _text = 'Hello World';
  String _imageCount = '';
  String _selectedImageUrl = '';
  bool _isLoading = false;

  Future<void> _calculateImageCount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var response = await http.get(
        Uri.parse(
            'https://text2image4.p.rapidapi.com/api/page-count?fileType=png&textType=plainText&text=$_text'),
        headers: {
          'x-rapidapi-key': '645228621bmshf0ae16afd17e9e2p140f91jsnf029457f37b4',
          'x-rapidapi-host': 'text2image4.p.rapidapi.com'
        },
      );

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        setState(() {
          _imageCount = decodedResponse['pageCount'].toString();
        });
      } else {
        setState(() {
          _imageCount = 'Failed to calculate image count: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _imageCount = 'Error calculating image count: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _convertTextToImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var response = await http.get(
        Uri.parse(
            'https://text2image4.p.rapidapi.com/api/converter?fileType=png&textType=plainText&text=$_text&width=300&height=300&padding=30&fontFamily=Arial&fontSize=64&backgroundColor=%230092d2&textColor=%23ffffff&pages=1'),
        headers: {
          'x-rapidapi-key': '645228621bmshf0ae16afd17e9e2p140f91jsnf029457f37b4',
          'x-rapidapi-host': 'text2image4.p.rapidapi.com'
        },
      );

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        setState(() {
          _selectedImageUrl = decodedResponse['imageUrl'];
        });
      } else {
        setState(() {
          _selectedImageUrl = 'Failed to convert text to image: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _selectedImageUrl = 'Error converting text to image: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to Images Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                _text = value;
              },
              decoration: InputDecoration(
                labelText: 'Enter Text',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateImageCount,
              child: Text('Calculate Image Count'),
            ),
            SizedBox(height: 20),
            if (_imageCount.isNotEmpty)
              Text(
                'Image Count: $_imageCount',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertTextToImage,
              child: Text('Convert Text to Image'),
            ),
            SizedBox(height: 20),
            if (_selectedImageUrl.isNotEmpty)
              Image.network(_selectedImageUrl),
            if (_isLoading)
              Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TextToImagesScreen(),
  ));
}
