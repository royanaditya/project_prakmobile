import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product.dart';

class HistoryPage extends StatefulWidget {
  final String username;
  const HistoryPage({super.key, required this.username});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> slips = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('history_${widget.username}') ?? [];
    setState(() {
      slips =
          history.map((e) => json.decode(e) as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembayaran'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: slips.isEmpty
          ? const Center(child: Text('Belum ada transaksi'))
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: slips.length,
                itemBuilder: (context, idx) {
                  final slip = slips[idx];
                  final productsRaw = slip['products'];
                  final products = (productsRaw is List)
                      ? productsRaw.map((p) => Product.fromJson(p)).toList()
                      : <Product>[];
                  final total = slip['total'];
                  final time = slip['timestamp'] != null
                      ? DateTime.tryParse(slip['timestamp'])
                      : null;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoryDetailPage(
                            products: products,
                            total: total,
                            timestamp: time,
                          ),
                        ),
                      ).then((_) => _loadHistory());
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.5),
                          width: 1.2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 18),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: products.isNotEmpty
                              ? Image.network(
                                  products.first.image,
                                  width: 54,
                                  height: 54,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, o, s) => Container(
                                    width: 54,
                                    height: 54,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image,
                                        size: 28),
                                  ),
                                )
                              : Container(
                                  width: 54,
                                  height: 54,
                                  color: Colors.grey[200],
                                  child:
                                      const Icon(Icons.broken_image, size: 28),
                                ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                products.isEmpty
                                    ? "Produk tidak ditemukan"
                                    : (products.length == 1
                                        ? products.first.name
                                        : "${products.first.name} +${products.length - 1} produk"),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber[700],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "LUNAS",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.1),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (time != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 4, bottom: 2),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 15, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            Row(
                              children: [
                                const Icon(Icons.attach_money,
                                    size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  "Total: \$${(total ?? 0).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right,
                            color: Colors.black54),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class HistoryDetailPage extends StatelessWidget {
  final List<Product> products;
  final double total;
  final DateTime? timestamp;

  const HistoryDetailPage({
    super.key,
    required this.products,
    required this.total,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      "Tanggal: ${timestamp!.day}/${timestamp!.month}/${timestamp!.year} ${timestamp!.hour}:${timestamp!.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) => const Divider(height: 18),
                itemBuilder: (context, i) {
                  final p = products[i];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text('Qty: ${p.quantity}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black54)),
                            ],
                          ),
                        ),
                        Text('\$${(p.price * p.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('Total:',
                      style: TextStyle(fontSize: 17, color: Colors.white70)),
                  const SizedBox(width: 8),
                  Text('\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
