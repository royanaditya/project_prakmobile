import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  void register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Error handling: cek semua input harus diisi
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi!')),
      );
      return;
    }

    // Menyimpan username dan password ke Secure Storage
    await _secureStorage.write(key: 'username', value: email);
    await _secureStorage.write(key: 'password', value: password);

    final prefs = await SharedPreferences.getInstance();
    // Ambil list user lama
    List<String> users = prefs.getStringList('users') ?? [];
    // Tambahkan user baru
    users.add(jsonEncode({'username': email, 'password': password}));
    await prefs.setStringList('users', users);

    // Simpan juga username/password terakhir untuk auto-login
    await prefs.setString('username', email);
    await prefs.setString('password', password);
    // Tidak perlu set isLoggedIn di sini, hanya saat login

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pendaftaran berhasil!')),
    );
    // Kembali ke halaman login setelah registrasi berhasil
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ganti icon dengan logo.png
              SizedBox(
                height: 72,
                width: 72,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/Logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Pendaftaran Pengguna',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700]),
              ),
              SizedBox(height: 8),
              Text(
                'Isi informasi untuk registrasi akun baru',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email / Username',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // warna hitam
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Daftar',
                    style: TextStyle(
                        fontSize: 18, color: Colors.white), // teks putih
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tambahkan tombol "Sudah punya akun? Silahkan login"
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  'Sudah punya akun? Silahkan login',
                  style: TextStyle(fontSize: 16, color: Colors.blue[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
