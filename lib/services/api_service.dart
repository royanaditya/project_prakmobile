import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://dummyjson.com/products';

  // Ambil daftar produk (mens-shirts)
  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['products'];
    } else {
      throw Exception('Gagal memuat data produk dari API');
    }
  }
}
