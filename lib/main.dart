import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'pages/login_pages.dart';
import 'pages/gallery_page.dart';
import 'pages/favorites_page.dart';

void main() {
  runApp(const MyApp());
}

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Notifikasi untuk memberitahu widget yang bergantung pada tema
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Galeri Aplikasi',
            theme: themeNotifier.isDarkMode
                ? ThemeData.dark()
                : ThemeData.light(),
            initialRoute: '/', // Arahkan ke halaman login pertama kali
            routes: {
              '/': (context) => const LoginPage(), // Halaman login
              '/gallery': (context) => const GalleryPage(), // Halaman galeri
              '/favorites': (context) => const FavoritesPage(), // Halaman favorit
            },
          );
        },
      ),
    );
  }
}
