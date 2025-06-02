class Product {
  final int id;
  final String name;
  final double price;
  final String image;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      image: json['image'],
    );
  }
}