import 'package:flutter/material.dart';
import 'gallery_page.dart'; // Pastikan Anda telah membuat halaman GalleryPage

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Simulasi data akun statis
  final List<Map<String, String>> _accounts = [
    {'username': 'irfan', 'password': 'D1andaru'},
  ];

  // Login statis
  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    bool isValidUser = _accounts.any((account) {
      return account['username'] == username && account['password'] == password;
    });

    if (isValidUser) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GalleryPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau Password salah!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar belakang gradien
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E2DE2), // Ubah warna menjadi lebih soft
                  Color(0xFF4A00E0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Judul halaman
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple.shade700, // Warna judul yang lebih menarik
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        // Input username
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8), // Warna latar belakang input
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // Input password
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8), // Warna latar belakang input
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        // Tombol login
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14.0,
                              horizontal: 32.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            backgroundColor: Colors.deepPurple.shade600, // Ubah warna tombol agar serasi
                            foregroundColor: Colors.white, // Warna teks menjadi putih
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
