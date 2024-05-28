import 'package:flutter/material.dart';
import 'html_to_pdf.dart';
import 'package:imagetopdf/screens/settings_screen.dart';
import 'package:imagetopdf/screens/PdfToTextScreen.dart';
import 'package:imagetopdf/screens/TextToImagesScreen.dart';
import 'package:imagetopdf/screens/book_search_screen.dart';
import 'package:imagetopdf/screens/imagetopdfConverter.dart'; // Import the Image to PDF screen

// Placeholder screens for the new functionalities
class AudioConversionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Conversion')),
      body: Center(child: Text('Audio Conversion Screen')),
    );
  }
}

class VideoConversionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Conversion')),
      body: Center(child: Text('Video Conversion Screen')),
    );
  }
}

class ImageConversionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Conversion')),
      body: Center(child: Text('Image Conversion Screen')),
    );
  }
}

class DocumentConversionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Document Conversion')),
      body: Center(child: Text('Document Conversion Screen')),
    );
  }
}

class EbookConversionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ebook Conversion')),
      body: Center(child: Text('Ebook Conversion Screen')),
    );
  }
}

class FileConversionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('File Conversion')),
      body: Center(child: Text('File Conversion Screen')),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('HTML to PDF'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HtmlToPdfPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.screen_share),
              title: Text('PDF to Text'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PdfToTextScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Text from Images'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TextToImagesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Book Search'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookSearchScreen()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('Image to PDF'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageToPdfConverter()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: <Widget>[
            _buildConversionButton(context, 'Audio', Icons.audiotrack, AudioConversionScreen()),
            _buildConversionButton(context, 'Video', Icons.videocam, VideoConversionScreen()),
            _buildConversionButton(context, 'Image', Icons.image, ImageConversionScreen()),
            _buildConversionButton(context, 'Document', Icons.description, DocumentConversionScreen()),
            _buildConversionButton(context, 'Ebook', Icons.book, EbookConversionScreen()),
            _buildConversionButton(context, 'File', Icons.insert_drive_file, FileConversionScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionButton(BuildContext context, String label, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 50, color: Colors.blue),
              SizedBox(height: 10),
              Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
