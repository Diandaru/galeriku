import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:irpan_gallery/pages/login_pages.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/database_helper.dart';
import 'favorites_page.dart';
import 'login_pages.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _imageFileList = [];
  Map<String, List<Map<String, dynamic>>> _groupedImages = {};
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final images = await DatabaseHelper.instance.getAllImages();
    Map<String, List<Map<String, dynamic>>> groupedImages = {};
    for (var image in images) {
      final DateTime dateAdded = DateTime.parse(image['date']);
      final String formattedDate =
          '${dateAdded.day}/${dateAdded.month}/${dateAdded.year}';

      if (groupedImages.containsKey(formattedDate)) {
        groupedImages[formattedDate]?.add(image);
      } else {
        groupedImages[formattedDate] = [image];
      }
    }

    setState(() {
      _imageFileList = images;
      _groupedImages = groupedImages;
    });
  }
  
  Future<void> _pickImage() async {
  final pickedFiles = await _picker.pickMultiImage();
  if (pickedFiles != null && pickedFiles.isNotEmpty) {
    for (var pickedFile in pickedFiles) {
      final imageFile = File(pickedFile.path);
      final date = DateTime.now();
      await DatabaseHelper.instance.insertImage(imageFile, date);
      _loadImages(); // Perbarui tampilan galeri setelah menambahkan gambar
    }
  }
}


  Future<void> _toggleFavorite(int id, int currentStatus) async {
    await DatabaseHelper.instance.toggleFavorite(id, currentStatus);
    _loadImages();
  }

  Future<void> _deleteImage(int id) async {
    await DatabaseHelper.instance.deleteImage(id);
    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Galeri'),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _pickImage,
            ),
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: _groupedImages.keys.map((date) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Tanggal: $date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _groupedImages[date]!.map((imageData) {
                      final imageBytes = imageData['image'] as List<int>;
                      final dateAdded = DateTime.parse(imageData['date']);
                      final formattedDate =
                          '${dateAdded.day}/${dateAdded.month}/${dateAdded.year}';
                      final imageWidget = Image.memory(
                        Uint8List.fromList(imageBytes),
                        fit: BoxFit.cover,
                      );

                      double imageSize = (MediaQuery.of(context).size.width - 40) / 4;

                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.memory(Uint8List.fromList(imageBytes)),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Foto ditambahkan pada $formattedDate",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              imageData['favorite'] == 1
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: imageData['favorite'] == 1
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            onPressed: () {
                                              _toggleFavorite(imageData['id'], imageData['favorite']);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text('Hapus Gambar'),
                                                    content: const Text(
                                                        'Apakah Anda yakin ingin menghapus gambar ini?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          _deleteImage(imageData['id']);
                                                          Navigator.of(context).pop();
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: const Text('Ya'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: const Text('Tidak'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: imageSize,
                            height: imageSize,
                            decoration: BoxDecoration(
                              color: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: imageWidget,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
