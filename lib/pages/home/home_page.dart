import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import 'profile_page.dart';
import 'bantuan_page.dart';
import '../product/product_detail_page.dart';
import '../product/cart_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../product/favorite_page.dart';
import '../../models/product.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _selectedCategoryIndex = 0;
  List<Product> cart = [];
  List<Product> favorites = [];
  List<dynamic> products = [];
  final List<String> fashionCategories = [
    'all',
    'mens-shirts',
    'mens-shoes',
    'mens-watches',
    'womens-dresses',
    'womens-shoes',
    'womens-watches',
    'womens-bags',
    'womens-jewellery',
    'sunglasses',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts({String? category}) async {
    final selectedCategory = category ?? fashionCategories[_selectedCategoryIndex];
    if (selectedCategory == 'all') {
      List<dynamic> allProducts = [];
      for (var cat in fashionCategories.skip(1)) {
        final url = 'https://dummyjson.com/products/category/$cat';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          allProducts.addAll(data['products']);
        }
      }
      setState(() {
        products = allProducts;
      });
    } else {
      final url = 'https://dummyjson.com/products/category/$selectedCategory';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data['products'];
        });
      } else {
        throw Exception('Gagal memuat kategori: $selectedCategory');
      }
    }
  }
  
  void _toggleFavorite(Product product) {
    setState(() {
      final idx = favorites.indexWhere((item) => item.id == product.id);
      if (idx != -1) {
        favorites.removeAt(idx);
      } else {
        favorites.add(product);
      }
    });
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

  Widget buildCategorySelector() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: fashionCategories.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final category = fashionCategories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                category == 'all' ? 'All Items' : category.replaceAll('-', ' '),
                style: const TextStyle(fontSize: 13),
              ),
              selected: _selectedCategoryIndex == index,
              selectedColor: Colors.black,
              onSelected: (_) {
                setState(() => _selectedCategoryIndex = index);
                _fetchProducts(category: category);
              },
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: _selectedCategoryIndex == index ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DressGo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartPage(cart: cart),
                ),
              );
            },
            tooltip: "Keranjang",
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
            tooltip: "Logout",
          ),
        ],
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // HOME PAGE
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'Hello, ${widget.username} 👋\nWelcome',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Tambahkan poster di sini
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/poster.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 140,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                buildCategorySelector(),
                const SizedBox(height: 8),
                Expanded(
                  child: products.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GridView.builder(
                            itemCount: products.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            itemBuilder: (context, i) {
                              final product = products[i];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailPage(
                                      product: product,
                                      onAddToCart: (rawProduct, quantity) {
                                        final index = cart.indexWhere((item) => item.id == rawProduct['id']);
                                        if (index != -1) {
                                          setState(() {
                                            cart[index].quantity += quantity;
                                          });
                                        } else {
                                          setState(() {
                                            cart.add(Product(
                                              id: rawProduct['id'],
                                              name: rawProduct['title'],
                                              price: double.parse(rawProduct['price'].toString()),
                                              image: rawProduct['thumbnail'],
                                              quantity: quantity,
                                            ));
                                          });
                                        }
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Produk ditambahkan ke keranjang")),
                                        );
                                      },
                                      onToggleFavorite: (rawProduct) {
                                        setState(() {
                                          final idx = favorites.indexWhere((item) => item.id == rawProduct['id']);
                                          if (idx != -1) {
                                            favorites.removeAt(idx);
                                          } else {
                                            favorites.add(Product(
                                              id: rawProduct['id'],
                                              name: rawProduct['title'],
                                              price: double.parse(rawProduct['price'].toString()),
                                              image: rawProduct['thumbnail'],
                                              quantity: 1,
                                            ));
                                          }
                                        });
                                      },
                                      isFavorite: favorites.any((item) => item.id == product['id']),
                                    ),
                                  ),
                                ),
                                child: Card(
                                  elevation: 5,
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Gambar produk memenuhi lebar card
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                        child: Image.network(
                                          product['thumbnail'],
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, o, s) => Container(
                                            height: 120,
                                            width: double.infinity,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.broken_image, size: 40),
                                          ),
                                        ),
                                      ),
                                      // Isi card tanpa space kosong
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product['title'],
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.star, size: 15, color: Colors.amber),
                                                const SizedBox(width: 4),
                                                Text(
                                                  product['rating'].toString(),
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '\$${product['price']}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.shopping_bag, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "Stock: ${product['stock'] ?? '-'}",
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  icon: Icon(
                                                    favorites.any((item) => item.id == product['id'])
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: favorites.any((item) => item.id == product['id'])
                                                        ? Colors.red
                                                        : null,
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    final prod = Product(
                                                      id: product['id'],
                                                      name: product['title'],
                                                      price: double.parse(product['price'].toString()),
                                                      image: product['thumbnail'],
                                                      quantity: 1,
                                                    );
                                                    _toggleFavorite(prod);
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  tooltip: "Like",
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
            // FAVORITES PAGE
            FavoritesPage(favorites: favorites),
            // PROFILE PAGE
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}