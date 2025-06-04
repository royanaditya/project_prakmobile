import 'package:flutter/material.dart';
import 'package:project_prakmobile/models/product.dart';

class FavoritesPage extends StatefulWidget {
  final List<Product> favorites;
  final VoidCallback? onChanged;
  const FavoritesPage({super.key, required this.favorites, this.onChanged});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  void _toggleFavorite(Product product) async {
    setState(() {
      widget.favorites.removeWhere((item) => item.id == product.id);
    });
    if (widget.onChanged != null) widget.onChanged!();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dihapus dari favorites!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: widget.favorites.isEmpty
          ? const Center(child: Text('No favorites yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.favorites.length,
              itemBuilder: (context, index) {
                final product = widget.favorites[index];
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
                            product.image,
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 70,
                              width: 70,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "\$${product.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () => _toggleFavorite(product),
                          tooltip: "Un-Like",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
