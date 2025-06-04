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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: widget.cart.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      final isSelected = selectedIndexes.contains(index);
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      selectedIndexes.add(index);
                                    } else {
                                      selectedIndexes.remove(index);
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () =>
                                              _reduceQuantity(index),
                                          splashRadius: 18,
                                        ),
                                        Text('Qty: ${item.quantity}'),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () => _addQuantity(index),
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
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _removeItem(index),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Total: \$${getTotalPrice().toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
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
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: selectedIndexes.isEmpty
                            ? null
                            : () async {
                                final selectedProducts = selectedIndexes
                                    .map((i) => widget.cart[i])
                                    .toList();
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentPage(
                                      total: getTotalPrice(),
                                      selectedProducts: selectedProducts,
                                      username: widget.username,
                                    ),
                                  ),
                                );
                                setState(() {
                                  final toRemove = selectedIndexes.toList()
                                    ..sort((a, b) => b.compareTo(a));
                                  for (final idx in toRemove) {
                                    widget.cart.removeAt(idx);
                                  }
                                  selectedIndexes.clear();
                                  _saveCart();
                                });
                              },
                        child: const Text('Lanjut ke Pembayaran'),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
