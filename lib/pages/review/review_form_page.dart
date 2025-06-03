import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:project_prakmobile/models/product.dart';

class ReviewFormPage extends StatefulWidget {
  final Function(Product) onSubmit;

  const ReviewFormPage({super.key, required this.onSubmit});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  File? _image;
  final picker = ImagePicker();
  final _nameController = TextEditingController();
  String? _category, _brand;
  double? _price;
  double? _rating;

  Future<void> _getImage() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  void _submitReview() {
    if (_image == null || _nameController.text.isEmpty || _price == null) return;

    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text,
      price: _price!,
      image: _image!.path,
      quantity: 1,
      brand: _brand,
      category: _category,
      rating: _rating,
    );

    widget.onSubmit(product);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Fashion Favorit"),
        actions: [
          TextButton(
            onPressed: _submitReview,
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _getImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt, size: 40, color: Colors.purple),
                          Text("Tap untuk tambah foto", style: TextStyle(color: Colors.purple)),
                          Text("Ambil foto fashion favoritmu", style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama Produk Fashion",
                prefixIcon: Icon(Icons.checkroom),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              items: ['Dress', 'Shirt', 'Pants', 'Shoes', 'Accessories'].map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (val) => setState(() => _category = val),
              decoration: const InputDecoration(
                labelText: "Kategori",
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: "Brand (opsional)",
                prefixIcon: Icon(Icons.store),
              ),
              onChanged: (val) => setState(() => _brand = val),
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Harga (Rp)",
                prefixIcon: Icon(Icons.price_change),
              ),
              onChanged: (val) {
                setState(() {
                  _price = double.tryParse(val) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.star),
              title: Text(_rating == null ? "Tap untuk beri rating" : "Rating: $_rating"),
              onTap: () async {
                final rating = await showDialog<double>(
                  context: context,
                  builder: (_) {
                    double tempRating = 5.0;
                    return AlertDialog(
                      title: const Text("Beri Rating"),
                      content: StatefulBuilder(
                        builder: (context, setState) {
                          return Slider(
                            min: 0,
                            max: 10,
                            divisions: 20,
                            label: tempRating.toString(),
                            value: tempRating,
                            onChanged: (val) => setState(() => tempRating = val),
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, tempRating),
                          child: const Text("OK"),
                        ),
                      ],
                    );
                  },
                );
                if (rating != null) {
                  setState(() => _rating = rating);
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Submit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 0, 158, 66),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submitReview,
            ),
          ],
        ),
      ),
    );
  }
}
