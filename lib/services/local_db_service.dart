import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class LocalDbService {
  static Database? _db;

  Future<Database> get db async {
    return _db ??= await _initDb();
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'products.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE products(id INTEGER PRIMARY KEY, name TEXT, price REAL, image TEXT)',
        );
      },
    );
  }

  Future<void> insertProduct(Product product) async {
    final dbClient = await db;
    await dbClient.insert('products', {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'image': product.image
    });
  }

  Future<List<Product>> getProducts() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('products');
    return maps.map((json) => Product.fromJson(json)).toList();
  }
}
