import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import 'profile_page.dart';
import '../product/product_detail_page.dart';
import '../product/cart_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../product/favorite_page.dart';
import '../product/history_page.dart';
import '../../models/product.dart';
import '../review/review_list_page.dart';

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

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _loadUserData();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Load cart
    final cartList = prefs.getStringList('cart_${widget.username}') ?? [];
    cart = cartList.map((e) => Product.fromJson(json.decode(e))).toList();
    // Load favorites
    final favList = prefs.getStringList('favorites_${widget.username}') ?? [];
    favorites = favList.map((e) => Product.fromJson(json.decode(e))).toList();
    setState(() {});
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = cart.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('cart_${widget.username}', cartJson);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favJson = favorites.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('favorites_${widget.username}', favJson);
  }

  Future<void> _fetchProducts({String? category}) async {
    final selectedCategory =
        category ?? fashionCategories[_selectedCategoryIndex];
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
      _saveFavorites();
    });
  }

  void addToCart(Map<String, dynamic> rawProduct) {
    final index = cart.indexWhere((item) => item.id == rawProduct['id']);
    if (index != -1) {
      setState(() {
        cart[index].quantity += 1;
        _saveCart();
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
        _saveCart();
      });
    }
    _showAddToCartDialog();
  }

  void addToCartFromFavorite(Product product) {
    final index = cart.indexWhere((item) => item.id == product.id);
    if (index != -1) {
      setState(() {
        cart[index].quantity += 1;
        _saveCart();
      });
    } else {
      setState(() {
        cart.add(Product(
          id: product.id,
          name: product.name,
          price: product.price,
          image: product.image,
          quantity: 1,
          brand: product.brand,
          category: product.category,
          rating: product.rating,
        ));
        _saveCart();
      });
    }
    _showAddToCartDialog();
  }

  void _showAddToCartDialog() {
    // Tutup dialog sebelumnya jika masih terbuka
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "AddedToCart",
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      "Produk berhasil ditambahkan ke keranjang!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      height: 4,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        child: const Text("Tutup"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Hanya hapus status login, jangan hapus username/password
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showLogoutDialog() {
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ya'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                // Jangan hapus username/password, hanya set status login ke false
                await prefs.setBool('isLoggedIn', false);
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
                color: _selectedCategoryIndex == index
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter produk berdasarkan searchQuery
    List<dynamic> filteredProducts = searchQuery.isEmpty
        ? products
        : products.where((p) {
            final name = (p['title'] ?? '').toString().toLowerCase();
            return name.contains(searchQuery);
          }).toList();

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
                  builder: (_) =>
                      CartPage(cart: cart, username: widget.username),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'Hello, ${widget.username} 👋\nWelcome',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Poster
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
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari barang...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                buildCategorySelector(),
                const SizedBox(height: 8),
                Expanded(
                  child: products.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : filteredProducts.isEmpty
                          ? const Center(child: Text('Barang tidak ada'))
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: GridView.builder(
                                itemCount: filteredProducts.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.65,
                                ),
                                itemBuilder: (context, i) {
                                  final product = filteredProducts[i];
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailPage(
                                          product: product,
                                          onAddToCart: (rawProduct, quantity) {
                                            final index = cart.indexWhere(
                                                (item) =>
                                                    item.id ==
                                                    rawProduct['id']);
                                            if (index != -1) {
                                              setState(() {
                                                cart[index].quantity +=
                                                    quantity;
                                              });
                                            } else {
                                              setState(() {
                                                cart.add(Product(
                                                  id: rawProduct['id'],
                                                  name: rawProduct['title'],
                                                  price: double.parse(
                                                      rawProduct['price']
                                                          .toString()),
                                                  image:
                                                      rawProduct['thumbnail'],
                                                  quantity: quantity,
                                                ));
                                              });
                                            }
                                            _showAddToCartDialog();
                                          },
                                          onToggleFavorite: (rawProduct) {
                                            setState(() {
                                              final idx = favorites.indexWhere(
                                                  (item) =>
                                                      item.id ==
                                                      rawProduct['id']);
                                              if (idx != -1) {
                                                favorites.removeAt(idx);
                                              } else {
                                                favorites.add(Product(
                                                  id: rawProduct['id'],
                                                  name: rawProduct['title'],
                                                  price: double.parse(
                                                      rawProduct['price']
                                                          .toString()),
                                                  image:
                                                      rawProduct['thumbnail'],
                                                  quantity: 1,
                                                ));
                                              }
                                            });
                                          },
                                          isFavorite: favorites.any((item) =>
                                              item.id == product['id']),
                                        ),
                                      ),
                                    ),
                                    child: Card(
                                      elevation: 5,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(14)),
                                            child: Image.network(
                                              product['thumbnail'],
                                              height: 120,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, o, s) =>
                                                  Container(
                                                height: 120,
                                                width: double.infinity,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                    Icons.broken_image,
                                                    size: 40),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product['title'],
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star,
                                                        size: 15,
                                                        color: Colors.amber),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      product['rating']
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      '\$${product['price']}',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.shopping_bag,
                                                        size: 14,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "Stock: ${product['stock'] ?? '-'}",
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.grey),
                                                    ),
                                                    const Spacer(),
                                                    IconButton(
                                                      icon: Icon(
                                                        favorites.any((item) =>
                                                                item.id ==
                                                                product['id'])
                                                            ? Icons.favorite
                                                            : Icons
                                                                .favorite_border,
                                                        color: favorites.any(
                                                                (item) =>
                                                                    item.id ==
                                                                    product[
                                                                        'id'])
                                                            ? Colors.red
                                                            : null,
                                                        size: 18,
                                                      ),
                                                      onPressed: () {
                                                        final prod = Product(
                                                          id: product['id'],
                                                          name:
                                                              product['title'],
                                                          price: double.parse(
                                                              product['price']
                                                                  .toString()),
                                                          image: product[
                                                              'thumbnail'],
                                                          quantity: 1,
                                                        );
                                                        _toggleFavorite(prod);
                                                      },
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          const BoxConstraints(),
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
            FavoritesPage(
              favorites: favorites,
              onChanged: _saveFavorites,
              onAddToCart: addToCartFromFavorite, // callback ke fungsi HomePage
            ),
            // HISTORY PAGE
            HistoryPage(username: widget.username),
            // PROFILE PAGE
            ProfilePage(),
            // ULASAN PAGE
            ReviewListPage(username: widget.username),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Ulasan'),
        ],
      ),
    );
  }
}
