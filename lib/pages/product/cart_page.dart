import 'package:flutter/material.dart';
import 'package:project_prakmobile/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'payment_page.dart';

class CartPage extends StatefulWidget {
  final List<Product> cart;
  final String username;
  const CartPage({super.key, required this.cart, required this.username});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Set untuk menyimpan index barang yang dipilih
  Set<int> selectedIndexes = {};
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  double getTotalPrice() {
    // Hitung total hanya dari barang yang dipilih
    return selectedIndexes.fold(0, (sum, idx) {
      final item = widget.cart[idx];
      return sum + (item.price * item.quantity);
    });
  }

  void _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = widget.cart.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('cart_${widget.username}', cartJson);
  }

  void _addQuantity(int index) {
    setState(() {
      widget.cart[index].quantity += 1;
      _saveCart();
    });
  }

  void _reduceQuantity(int index) {
    setState(() {
      if (widget.cart[index].quantity > 1) {
        widget.cart[index].quantity -= 1;
        _saveCart();
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      widget.cart.removeAt(index);
      // Hapus dari selection jika dihapus
      selectedIndexes.remove(index);
      // Perbaiki index selection setelah penghapusan
      selectedIndexes = selectedIndexes
          .map((i) => i > index ? i - 1 : i)
          .where((i) => i < widget.cart.length)
          .toSet();
      _saveCart();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (selectedIndexes.length == widget.cart.length) {
        selectedIndexes.clear();
      } else {
        selectedIndexes =
            Set<int>.from(List.generate(widget.cart.length, (i) => i));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _saveCart();
    // Default: semua barang tidak terpilih
    selectedIndexes.clear();
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

  @override
  Widget build(BuildContext context) {
    // Filter cart berdasarkan searchQuery
    List<Product> filteredCart = searchQuery.isEmpty
        ? widget.cart
        : widget.cart.where((item) {
            return item.name.toLowerCase().contains(searchQuery);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        actions: [
          if (widget.cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 18, top: 10),
              child: CircleAvatar(
                backgroundColor: Colors.amber[700],
                radius: 16,
                child: Text(
                  '${widget.cart.length}',
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: widget.cart.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari barang di keranjang...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCart.length,
                    itemBuilder: (context, index) {
                      final item = filteredCart[index];
                      final realIndex = widget.cart.indexOf(item);
                      final isSelected = selectedIndexes.contains(realIndex);
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.09),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: isSelected
                              ? Border.all(color: Colors.amber, width: 2)
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: isSelected,
                                activeColor: Colors.amber[700],
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      selectedIndexes.add(realIndex);
                                    } else {
                                      selectedIndexes.remove(realIndex);
                                    }
                                  });
                                },
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.image,
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 60,
                                    width: 60,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image,
                                        size: 32),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline),
                                          color: Colors.red[400],
                                          onPressed: () =>
                                              _reduceQuantity(realIndex),
                                          splashRadius: 18,
                                        ),
                                        Text('Qty: ${item.quantity}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.add_circle_outline),
                                          color: Colors.green[700],
                                          onPressed: () =>
                                              _addQuantity(realIndex),
                                          splashRadius: 18,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _removeItem(realIndex),
                                    splashRadius: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Total: \$${getTotalPrice().toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          TextButton.icon(
                            onPressed:
                                widget.cart.isEmpty ? null : _toggleSelectAll,
                            icon: Icon(
                              selectedIndexes.length == widget.cart.length
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: Colors.black,
                            ),
                            label: const Text(
                              "Pilih Semua",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.payment, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                        ),
                        onPressed: selectedIndexes.isEmpty
                            ? null
                            : () async {
                                final selectedProducts = selectedIndexes
                                    .map((i) => widget.cart[i])
                                    .toList();
                                // Tunggu hasil pembayaran, jika sukses baru hapus barang
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentPage(
                                      total: getTotalPrice(),
                                      selectedProducts: selectedProducts,
                                      username: widget.username,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    final toRemove = selectedIndexes.toList()
                                      ..sort((a, b) => b.compareTo(a));
                                    for (final idx in toRemove) {
                                      widget.cart.removeAt(idx);
                                    }
                                    selectedIndexes.clear();
                                    _saveCart();
                                  });
                                }
                              },
                        label: const Text(
                          'Lanjut ke Pembayaran',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
