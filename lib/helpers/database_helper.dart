import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

// Memastikan database siap digunakan.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gallery.db');
    return _database!;
  }

// Menentukan path database dan mempersiapkan koneksi.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path,
        version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

// Mengatur struktur tabel untuk menyimpan gambar, tanggal, dan status favorit.
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const blobType = 'BLOB';
    const intType = 'INTEGER'; // For the favorite column

    await db.execute('''
    CREATE TABLE images ( 
      id $idType, 
      image $blobType, 
      date $textType, 
      favorite $intType DEFAULT 0 
    )''');
  }

// Menambahkan kolom baru (favorite) jika belum ada.
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE images ADD COLUMN favorite INTEGER DEFAULT 0
      ''');
    }
  }

// Menyimpan gambar dalam bentuk byte array dengan informasi tambahan (tanggal, status favorit).
  Future<int> insertImage(File imageFile, DateTime date) async {
    final db = await instance.database;
    final imageBytes = await imageFile.readAsBytes();
    final dateString = date.toIso8601String();

    return await db.insert('images', {
      'image': imageBytes,
      'date': dateString,
      'favorite': 0,
    });
  }

//  Mengelola penghapusan data dari database.
  Future<int> deleteImage(int id) async {
    final db = await instance.database;
    return await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }

// Menampilkan semua gambar dalam aplikasi.
  Future<List<Map<String, dynamic>>> getAllImages() async {
    final db = await instance.database;
    return await db.query('images');
  }

// Mengatur status favorit untuk gambar tertentu.
  Future<void> toggleFavorite(int id, int currentStatus) async {
    final db = await instance.database;
    await db.update(
        'images',
        {
          'favorite': currentStatus == 0 ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

// Menampilkan gambar yang telah ditandai sebagai favorit.
  Future<List<Map<String, dynamic>>> getFavoriteImages() async {
    final db = await instance.database;
    return await db.query('images', where: 'favorite = ?', whereArgs: [1]);
  }
}
