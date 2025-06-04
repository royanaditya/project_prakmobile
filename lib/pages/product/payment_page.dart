import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/product.dart';

class PaymentPage extends StatelessWidget {
  final double total;
  final List<Product> selectedProducts;
  final String username;
  const PaymentPage({
    super.key,
    required this.total,
    required this.selectedProducts,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: selectedProducts.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, i) {
                  final p = selectedProducts[i];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          p.image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text('Qty: ${p.quantity}',
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      Text('\$${(p.price * p.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text('Total yang harus dibayar:', style: TextStyle(fontSize: 18)),
            Text('USD ${total.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final slip = json.encode({
                  'products': selectedProducts.map((e) => e.toJson()).toList(),
                  'total': total,
                  'timestamp': DateTime.now().toIso8601String(),
                });
                List<String> history =
                    prefs.getStringList('history_${username}') ?? [];
                history.insert(0, slip);
                await prefs.setStringList('history_${username}', history);
                await prefs.setStringList('cart_${username}', []);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pembayaran berhasil!')),
                );
                Navigator.pop(context); // pop ke CartPage
              },
              child: const Text('Bayar Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
