import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_prakmobile/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'review_form_page.dart';

class ReviewListPage extends StatefulWidget {
  final String username;
  const ReviewListPage({super.key, required this.username});

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  List<Product> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final reviewList = prefs.getStringList('reviews_${widget.username}') ?? [];
    setState(() {
      _reviews =
          reviewList.map((e) => Product.fromJson(json.decode(e))).toList();
    });
  }

  Future<void> _saveReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final reviewJson = _reviews.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('reviews_${widget.username}', reviewJson);
  }

  void _addReview(Product product) {
    setState(() {
      _reviews.insert(0, product);
      _saveReviews();
    });
  }

  void _deleteReview(int index) {
    setState(() {
      _reviews.removeAt(index);
      _saveReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📷Fashion Review Page📷"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: _reviews.isEmpty
                ? const Center(child: Text("Belum ada fashion favorit"))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _reviews.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final item = _reviews[index];
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  color: Colors.grey.withOpacity(0.2),
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  child: Image(
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    image: item.image.startsWith("http")
                                        ? NetworkImage(item.image)
                                        : FileImage(File(item.image))
                                            as ImageProvider,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              size: 14, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            (item.rating?.toStringAsFixed(1) ??
                                                '-'),
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      Text(item.category ?? '-',
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                      Text(
                                        item.brand ?? '',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        "Rp ${item.price.toStringAsFixed(0)}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => _deleteReview(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.delete,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.camera_alt),
        label: const Text("Tambah Fashion"),
        backgroundColor: Color.fromARGB(255, 187, 200, 7),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewFormPage(onSubmit: _addReview),
            ),
          );
        },
      ),
    );
  }
}