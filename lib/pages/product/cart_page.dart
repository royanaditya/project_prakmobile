import 'package:flutter/material.dart';
import 'package:project_prakmobile/models/product.dart';
import 'payment_page.dart';

class CartPage extends StatelessWidget {
  final List<Product> cart;
  const CartPage({super.key, required this.cart});

  double getTotalPrice() {
    return cart.fold(0, (sum, item) => sum + (item.price * (item.quantity)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: cart.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        leading: Image.network(item.image, width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(item.name),
                        subtitle: Text('Qty: ${item.quantity}'),
                        trailing: Text('Rp ${(item.price * item.quantity).toStringAsFixed(2)}'),
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
                        'Total: Rp ${getTotalPrice().toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: cart.isEmpty
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
