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
                    padding: const EdgeInsets.all(12),
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
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
                                    child: const Icon(Icons.broken_image, size: 32),
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
                                          onPressed: () => _reduceQuantity(index),
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
                                    icon: const Icon(Icons.delete, color: Colors.red),
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
                      Text(
                        'Total: \$${getTotalPrice().toStringAsFixed(2)}',
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