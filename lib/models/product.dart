class Product {
  final int id;
  final String name;
  final double price;
  final String image;
  int quantity;
  final String? brand;
  final String? category;
  final double? rating;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
    this.brand,
    this.category,
    this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      image: json['image'],
      quantity: json['quantity'] ?? 1,
      brand: json['brand'],
      category: json['category'],
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'quantity': quantity,
      'brand': brand,
      'category': category,
      'rating': rating,
    };
  }
}
