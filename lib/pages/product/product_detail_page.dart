import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar perangkat
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(product['title']),
        backgroundColor: Colors.blue[600],
      ),
      body: SingleChildScrollView(  // Membuat konten scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar dengan ukuran responsif
              Container(
                width: screenWidth * 0.9, // Menggunakan 90% lebar layar
                height: screenHeight * 0.4, // Menggunakan 40% tinggi layar
                child: Image.network(
                  product['images'][0],
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              Text(
                product['title'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Harga: \$${product['price']}'),
              SizedBox(height: 10),
              Row(
                children: List.generate(
                  product['rating'].toInt(),
                  (index) => Icon(Icons.star, size: 20, color: Colors.yellow),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Deskripsi: ${product['description']}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
