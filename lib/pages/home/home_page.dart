import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import 'profile_page.dart';
import 'bantuan_page.dart';
import '../product/product_detail_page.dart';
import '../product/cart_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/product.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Product> cart = [];
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products/category/mens-shirts'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body)['products'];
      });
    } else {
      throw Exception('Gagal memuat data produk');
    }
  }

  void addToCart(Map<String, dynamic> rawProduct) {
    final index = cart.indexWhere((item) => item.id == rawProduct['id']);
    if (index != -1) {
      setState(() {
        cart[index].quantity += 1;
      });
    } else {
      setState(() {
        cart.add(Product(
          id: rawProduct['id'],
          name: rawProduct['title'],
          price: rawProduct['price'].toDouble(),
          image: rawProduct['thumbnail'],
          quantity: 1,
        ));
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk ditambahkan ke keranjang")),
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(onPressed: () {
            Navigator.pop(context);
            _logout();
          }, child: const Text("Logout")),
        ],
      ),
    );
  }

  Widget buildProductList() {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              ListTile(
                leading: Image.network(product['thumbnail'], width: 50, height: 50, fit: BoxFit.cover),
                title: Text(product['title']),
                subtitle: Text('Harga: \$${product['price']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: product),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => addToCart(product),
                    child: const Text("Masukkan ke Keranjang"),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Beranda"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartPage(cart: cart)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Text("Selamat datang, ${widget.username}", style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : buildProductList(),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Bantuan'),
        ],
      ),
    );
  }
}