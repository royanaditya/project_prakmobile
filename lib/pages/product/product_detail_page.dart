// product_detail_page.dart
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic> product, int quantity)? onAddToCart;
  final Function(Map<String, dynamic> product)? onToggleFavorite;
  final bool isFavorite;

  const ProductDetailPage({
    Key? key,
    required this.product,
    this.onAddToCart,
    this.onToggleFavorite,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _addToCart() {
    if (widget.onAddToCart != null) {
      widget.onAddToCart!(widget.product, quantity);
      _showAddToCartDialog();
    }
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

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (widget.onToggleFavorite != null) {
      widget.onToggleFavorite!(widget.product);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite
            ? 'Ditambahkan ke favorites!'
            : 'Dihapus dari favorites!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    product['images'][0],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share_outlined,
                            color: Colors.black),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product['title'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : Colors.black,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text("${product['rating']}",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product['description'],
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 20),
                    const Text("Choose amount",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() {
                              if (quantity > 1) quantity--;
                            });
                          },
                        ),
                        Text('$quantity', style: const TextStyle(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Price\n\$${(product['price'] * quantity).toStringAsFixed(2)}", // Harga menyesuaikan jumlah
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.black, // warna hitam
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _addToCart,
                        icon: const Icon(Icons.shopping_cart_checkout),
                        label: const Text("Masukkan ke Keranjang"),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
