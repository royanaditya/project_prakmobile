import 'package:flutter/material.dart';
import 'package:project_prakmobile/models/product.dart';
import 'payment_page.dart';

class CartPage extends StatefulWidget {
  final List<Product> cart;
  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double getTotalPrice() {
    return widget.cart.fold(0, (sum, item) => sum + (item.price * (item.quantity)));
  }

  void _addQuantity(int index) {
    setState(() {
      widget.cart[index].quantity += 1;
    });
  }

  void _reduceQuantity(int index) {
    setState(() {
      if (widget.cart[index].quantity > 1) {
        widget.cart[index].quantity -= 1;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      widget.cart.removeAt(index);
    });
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
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      return ListTile(
                        leading: Image.network(item.image, width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(item.name),
                        subtitle: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _reduceQuantity(index),
                            ),
                            Text('Qty: ${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _addQuantity(index),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'), // Ubah ke dollar
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(index),
                            ),
                          ],
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
                      Text(
                        'Total: \$${getTotalPrice().toStringAsFixed(2)}', // Ubah ke dollar
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: widget.cart.isEmpty
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentPage(total: getTotalPrice()),
                                  ),
                                );
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