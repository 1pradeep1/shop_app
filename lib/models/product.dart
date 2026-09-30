class Product {
  final int id;
  final String title, description, category, thumbnail;
  final String? brand;
  final double price, rating;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.thumbnail,
    required this.price,
    required this.rating,
    this.brand,
  });

  // Turns one JSON object from the API into a typed Product.
  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as int,
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        category: j['category'] as String? ?? '',
        thumbnail: j['thumbnail'] as String? ?? '',
        brand: j['brand'] as String?,
        price: (j['price'] as num).toDouble(),
        rating: (j['rating'] as num? ?? 0).toDouble(),
      );
}
