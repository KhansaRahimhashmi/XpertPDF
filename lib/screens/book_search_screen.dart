import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BookSearchScreen extends StatefulWidget {
  @override
  _BookSearchScreenState createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List _books = [];

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a search term')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _books = [];
    });

    final String apiUrl = 'https://getbooksinfo.p.rapidapi.com/search/';
    try {
      final response = await http.get(
        Uri.parse(apiUrl).replace(queryParameters: {'q': query}),
        headers: {
          'X-RapidAPI-Key': '0e5c7f9c21msh2abe22a023d60d8p1c80d7jsn0de3dc0d8b14',
          'X-RapidAPI-Host': 'getbooksinfo.p.rapidapi.com'
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print(responseBody); // Log the response body for debugging
        setState(() {
          _books = responseBody['books'] ?? []; // Adjust the key based on actual API response
          _isLoading = false;
        });
      } else {
        _handleError('Failed to load books: ${response.reasonPhrase}');
      }
    } catch (e) {
      _handleError('An error occurred: $e');
    }
  }

  void _handleError(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openBookUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the URL')),
      );
    }
  }

  Future<void> _downloadBook(String url, String filename) async {
    try {
      if (await _requestPermission(Permission.storage)) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final directory = await getExternalStorageDirectory();
          final file = File('${directory!.path}/$filename.pdf');
          await file.writeAsBytes(response.bodyBytes);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloaded to ${file.path}')),
          );
        } else {
          _handleError('Failed to download book');
        }
      } else {
        _handleError('Storage permission denied');
      }
    } catch (e) {
      _handleError('An error occurred while downloading: $e');
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  void _viewBook(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/temp_book.pdf');
      await file.writeAsBytes(response.bodyBytes);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(file.path),
        ),
      );
    } else {
      _handleError('Failed to load book for viewing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a book',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchBooks(_searchController.text);
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _books.isEmpty
                ? Center(child: Text('No books found'))
                : Expanded(
              child: ListView.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  var book = _books[index];
                  return ListTile(
                    title: Text(book['title'] ?? 'No title'),
                    subtitle: Text(book['author'] ?? 'No author'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.download),
                          onPressed: () {
                            _downloadBook(
                                book['pdfLink'], book['title']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.open_in_new),
                          onPressed: () {
                            _viewBook(book['pdfLink']);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String path;
  PDFViewerScreen(this.path);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: path,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BookSearchScreen(),
  ));
}
