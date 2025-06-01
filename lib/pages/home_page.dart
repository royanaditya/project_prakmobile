import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'bantuan_page.dart';
import 'dart:convert';  // Import json package untuk parsing data
import 'package:http/http.dart' as http;
import '../product/product_detail_page.dart';  // Import dengan path yang sesuai

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String username = '';
  List<dynamic> products = [];  // List untuk menyimpan produk

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _fetchProducts();  // Mengambil data produk saat halaman diinisialisasi
  }

  // Memeriksa status login saat aplikasi pertama kali dibuka
  void _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  // Fungsi untuk mengambil data produk dari API
  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products/category/mens-shirts'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body)['products'];  // Menyimpan data produk
      });
    } else {
      throw Exception('Gagal memuat data produk');
    }
  }

  // Menampilkan dialog konfirmasi untuk logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              child: Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog dan tetap di halaman ini
              },
            ),
            TextButton(
              child: Text('Ya'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('username');  // Hapus data username
                await prefs.setBool('isLoggedIn', false);  // Set status login menjadi false
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Widget untuk menampilkan daftar produk
  Widget buildProductList() {
    return ListView.builder(
      itemCount: products.length,  // Jumlah produk yang akan ditampilkan
      itemBuilder: (context, index) {
        var product = products[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Image.network(product['thumbnail'], width: 50, height: 50, fit: BoxFit.cover),
            title: Text(product['title'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Harga: \$${product['price']}'),
                Row(
                  children: List.generate(
                    product['rating'].toInt(),  // Menampilkan rating dengan bintang
                    (index) => Icon(Icons.star, size: 16, color: Colors.yellow),
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigasi ke halaman detail produk
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Widget untuk menampilkan konten Profile
  Widget buildProfileContent() {
    return ProfilePage();
  }

  // Widget untuk menampilkan konten Bantuan
  Widget buildHelpContent() {
    return BantuanPage();
  }

  // Widget untuk menampilkan konten Cart sementara
  Widget buildCartContent() {
    return Center(
      child: Text(
        'Cek untuk melanjutkan di cart', // Teks sementara di Cart
        style: TextStyle(fontSize: 18, color: Colors.blue[600]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Beranda'),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),  // Menampilkan dialog logout
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[600],
                      child: const Icon(Icons.group, color: Colors.white), // Ganti icon menjadi group
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Selamat Datang ${widget.username}', // Menampilkan nama kelompok
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: products.isEmpty
                    ? Center(child: CircularProgressIndicator())  // Tampilkan loading saat data sedang dimuat
                    : buildProductList(),  // Menampilkan daftar produk
              ),
            ],
          ),
          buildCartContent(),  // Konten untuk Cart
          buildProfileContent(),
          buildHelpContent(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'), // Cart item
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'), // Profile item
        ],
      ),
    );
  }
}
