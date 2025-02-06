import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _favoriteImages = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final images = await DatabaseHelper.instance.getFavoriteImages();
    setState(() {
      _favoriteImages = images;
    });
  }

  void _showImageDetail(BuildContext context, List<int> imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.memory(Uint8List.fromList(imageBytes)),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: _favoriteImages.isEmpty
          ? const Center(child: Text('No favorites yet!'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _favoriteImages.length,
                itemBuilder: (context, index) {
                  final imageData = _favoriteImages[index];
                  final imageBytes = imageData['image'] as List<int>;
                  final image = Image.memory(
                    Uint8List.fromList(imageBytes),
                    fit: BoxFit.cover,
                  );

                  return GestureDetector(
                    onTap: () {
                      _showImageDetail(context, imageBytes);
                    },
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: image,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
