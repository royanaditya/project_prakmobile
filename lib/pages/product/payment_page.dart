import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final double total;
  const PaymentPage({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Total yang harus dibayar:', style: TextStyle(fontSize: 18)),
              Text('Rp ${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pembayaran berhasil!')),
                  );
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Bayar Sekarang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
