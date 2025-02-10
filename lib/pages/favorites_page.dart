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

  Future<void> _toggleFavorite(int imageId) async {
    await DatabaseHelper.instance.removeFromFavorites(imageId);
    setState(() {
      _favoriteImages.removeWhere((image) => image['id'] == imageId); // Hapus dari daftar favorit
    });
  }

  void _showImageDetail(BuildContext context, List<int> imageBytes, int imageId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.memory(Uint8List.fromList(imageBytes)),
            const SizedBox(height: 10),
            const Text("Foto ditambahkan pada:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(_getDateFromImageId(imageId)), // Menampilkan tanggal foto ditambahkan
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    await _toggleFavorite(imageId);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi dummy untuk mendapatkan tanggal berdasarkan ID (Sesuaikan dengan database Anda)
  String _getDateFromImageId(int imageId) {
    // Contoh: Anda bisa mengganti ini dengan query database jika data tersedia
    return "10 Februari 2025";
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
                  final imageId = imageData['id'] as int;
                  final image = Image.memory(
                    Uint8List.fromList(imageBytes),
                    fit: BoxFit.cover,
                  );

                  return GestureDetector(
                    onTap: () => _showImageDetail(context, imageBytes, imageId),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: image,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => _toggleFavorite(imageId),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
